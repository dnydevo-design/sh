import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/peer_invite.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/transfer_progress.dart';
import 'network_address_service.dart';

class OutgoingSocketSession {
  const OutgoingSocketSession({
    required this.invite,
    required this.completion,
    required this.dispose,
  });

  final PeerInvite invite;
  final Future<List<TransferFile>> completion;
  final Future<void> Function() dispose;
}

class SocketTransferService {
  SocketTransferService(this._networkAddressService);

  final NetworkAddressService _networkAddressService;

  Future<OutgoingSocketSession> hostFiles({
    required List<TransferFile> files,
    required String displayName,
    PeerTransport transport = PeerTransport.socket,
    required void Function(TransferProgress progress) onProgress,
  }) async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final host = await _networkAddressService.preferredIPv4Address();
    final sessionId = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final completion = Completer<List<TransferFile>>();
    var activePeers = 0;
    late final StreamSubscription<Socket> subscription;

    onProgress(
      TransferProgress(
        phase: TransferPhase.waitingForPeer,
        bytesTransferred: 0,
        totalBytes: totalBytes,
        startedAt: null,
      ),
    );

    subscription = server.listen(
      (socket) async {
        if (activePeers >= AppConstants.maxGroupPeers) {
          await socket.close();
          return;
        }
        activePeers++;
        try {
          final sentFiles = await _sendFiles(
            socket: socket,
            files: files,
            sessionId: sessionId,
            onProgress: onProgress,
          );
          if (!completion.isCompleted) {
            completion.complete(sentFiles);
          }
        } catch (error) {
          if (!completion.isCompleted) {
            completion.completeError(error);
          }
          onProgress(
            TransferProgress(
              phase: TransferPhase.failed,
              bytesTransferred: 0,
              totalBytes: totalBytes,
              startedAt: null,
              errorMessage: error.toString(),
            ),
          );
        } finally {
          activePeers--;
          await socket.close();
        }
      },
      onError: (Object error) {
        if (!completion.isCompleted) {
          completion.completeError(error);
        }
      },
    );

    return OutgoingSocketSession(
      invite: PeerInvite(
        sessionId: sessionId,
        host: host,
        port: server.port,
        transport: transport,
        displayName: displayName,
      ),
      completion: completion.future,
      dispose: () async {
        await subscription.cancel();
        await server.close();
      },
    );
  }

  Future<List<TransferFile>> receive({
    required PeerInvite invite,
    required Directory targetDirectory,
    required void Function(TransferProgress progress) onProgress,
  }) async {
    await targetDirectory.create(recursive: true);
    final socket = await Socket.connect(
      invite.host,
      invite.port,
      timeout: const Duration(seconds: 12),
    );
    try {
      final reader = _SocketByteReader(socket);
      final manifest = await _readJsonFrame(reader);
      final fileEntries = (manifest['files'] as List<Object?>)
          .cast<Map<String, Object?>>();
      final totalBytes = fileEntries.fold<int>(
        0,
        (sum, entry) => sum + ((entry['sizeBytes'] as num?)?.toInt() ?? 0),
      );
      final targets = <String, _ReceiveTarget>{};
      final offsets = <String, int>{};
      for (final entry in fileEntries) {
        final id = entry['id'] as String;
        final safeName = _safeFileName(entry['name'] as String? ?? 'file.bin');
        final size = (entry['sizeBytes'] as num?)?.toInt() ?? 0;
        final target = await _receiveTargetFor(
          directory: targetDirectory,
          fileId: id,
          safeName: safeName,
          sizeBytes: size,
        );
        targets[id] = target;
        offsets[id] = target.offsetBytes;
      }
      _writeJsonFrame(socket, {
        'sessionId': invite.sessionId,
        'resumeOffsets': offsets,
      });
      await socket.flush();
      final start = DateTime.now();
      var transferred = offsets.values.fold<int>(0, (sum, value) => sum + value);
      final received = <TransferFile>[];

      for (final entry in fileEntries) {
        final id = entry['id'] as String;
        final target = targets[id]!;
        final size = (entry['sizeBytes'] as num?)?.toInt() ?? 0;
        final remaining = size - target.offsetBytes;
        if (remaining > 0) {
          final sink = File(target.partialPath).openWrite(mode: FileMode.append);
          await reader.pipeExact(
            sink: sink,
            byteCount: remaining,
            onChunk: (chunkSize) {
              transferred += chunkSize;
              onProgress(
                TransferProgress(
                  phase: TransferPhase.transferring,
                  bytesTransferred: transferred,
                  totalBytes: totalBytes,
                  startedAt: start,
                  currentFileName: target.safeName,
                ),
              );
            },
          );
          await sink.flush();
          await sink.close();
          await File(target.partialPath).rename(target.finalPath);
        }
        received.add(TransferFile.fromManifestJson(entry, target.finalPath));
      }

      onProgress(
        TransferProgress(
          phase: TransferPhase.completed,
          bytesTransferred: totalBytes,
          totalBytes: totalBytes,
          startedAt: start,
        ),
      );
      return received;
    } finally {
      await socket.close();
    }
  }

  Future<List<TransferFile>> _sendFiles({
    required Socket socket,
    required List<TransferFile> files,
    required String sessionId,
    required void Function(TransferProgress progress) onProgress,
  }) async {
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final manifest = {
      'version': AppConstants.socketProtocolVersion,
      'sessionId': sessionId,
      'files': files.map((file) => file.toManifestJson()).toList(),
    };
    _writeJsonFrame(socket, manifest);
    await socket.flush();
    final reader = _SocketByteReader(socket);
    final resumeRequest = await _readJsonFrame(reader);
    final resumeOffsetsRaw =
        resumeRequest['resumeOffsets'] as Map<String, Object?>? ?? {};
    final resumeOffsets = resumeOffsetsRaw.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );

    final start = DateTime.now();
    var transferred = files.fold<int>(
      0,
      (sum, file) =>
          sum + (resumeOffsets[file.id] ?? 0).clamp(0, file.sizeBytes).toInt(),
    );
    for (final file in files) {
      final source = File(file.path);
      final offset =
          (resumeOffsets[file.id] ?? 0).clamp(0, file.sizeBytes).toInt();
      if (offset >= file.sizeBytes) {
        continue;
      }
      await for (final chunk in source.openRead(offset).transform(_chunker())) {
          transferred += chunk.length;
          onProgress(
            TransferProgress(
              phase: TransferPhase.transferring,
              bytesTransferred: transferred,
              totalBytes: totalBytes,
              startedAt: start,
              currentFileName: file.name,
            ),
          );
          socket.add(chunk);
        }
      await socket.flush();
    }
    onProgress(
      TransferProgress(
        phase: TransferPhase.completed,
        bytesTransferred: totalBytes,
        totalBytes: totalBytes,
        startedAt: start,
      ),
    );
    return files;
  }

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<String> _uniquePath(Directory directory, String name) async {
    final dotIndex = name.lastIndexOf('.');
    final base = dotIndex == -1 ? name : name.substring(0, dotIndex);
    final extension = dotIndex == -1 ? '' : name.substring(dotIndex);
    var candidate = '${directory.path}${Platform.pathSeparator}$name';
    var index = 1;
    while (await File(candidate).exists()) {
      candidate = '${directory.path}${Platform.pathSeparator}$base ($index)$extension';
      index++;
    }
    return candidate;
  }

  Future<_ReceiveTarget> _receiveTargetFor({
    required Directory directory,
    required String fileId,
    required String safeName,
    required int sizeBytes,
  }) async {
    final preferredPath = '${directory.path}${Platform.pathSeparator}$safeName';
    final completed = File(preferredPath);
    if (await completed.exists() && await completed.length() == sizeBytes) {
      return _ReceiveTarget(
        safeName: safeName,
        finalPath: preferredPath,
        partialPath: '$preferredPath.part.$fileId',
        offsetBytes: sizeBytes,
      );
    }

    final preferredPartialPath = '$preferredPath.part.$fileId';
    final preferredPartial = File(preferredPartialPath);
    if (await preferredPartial.exists()) {
      final offset = await preferredPartial.length();
      return _ReceiveTarget(
        safeName: safeName,
        finalPath: preferredPath,
        partialPath: preferredPartialPath,
        offsetBytes: math.min(offset, sizeBytes),
      );
    }

    final finalPath = await _uniquePath(directory, safeName);
    final partialPath = '$finalPath.part.$fileId';
    final partial = File(partialPath);
    final offset = await partial.exists() ? await partial.length() : 0;
    return _ReceiveTarget(
      safeName: safeName,
      finalPath: finalPath,
      partialPath: partialPath,
      offsetBytes: math.min(offset, sizeBytes),
    );
  }

  void _writeJsonFrame(Socket socket, Map<String, Object?> value) {
    final bytes = utf8.encode(jsonEncode(value));
    final lengthBytes = ByteData(4)..setUint32(0, bytes.length);
    socket
      ..add(lengthBytes.buffer.asUint8List())
      ..add(bytes);
  }

  Future<Map<String, Object?>> _readJsonFrame(_SocketByteReader reader) async {
    final headerLengthBytes = await reader.readExact(4);
    final headerLength = ByteData.sublistView(headerLengthBytes).getUint32(0);
    final headerBytes = await reader.readExact(headerLength);
    return jsonDecode(utf8.decode(headerBytes)) as Map<String, Object?>;
  }

  StreamTransformer<List<int>, List<int>> _chunker() {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        var offset = 0;
        while (offset < data.length) {
          final end = math.min(offset + AppConstants.socketChunkSize, data.length);
          sink.add(data.sublist(offset, end));
          offset = end;
        }
      },
    );
  }
}

class _ReceiveTarget {
  const _ReceiveTarget({
    required this.safeName,
    required this.finalPath,
    required this.partialPath,
    required this.offsetBytes,
  });

  final String safeName;
  final String finalPath;
  final String partialPath;
  final int offsetBytes;
}

class _SocketByteReader {
  _SocketByteReader(Stream<List<int>> source)
      : _iterator = StreamIterator<List<int>>(source);

  final StreamIterator<List<int>> _iterator;
  List<int> _buffer = const [];
  int _offset = 0;

  Future<Uint8List> readExact(int byteCount) async {
    final builder = BytesBuilder(copy: false);
    await _readLoop(byteCount, (chunk) => builder.add(chunk));
    return builder.takeBytes();
  }

  Future<void> pipeExact({
    required IOSink sink,
    required int byteCount,
    required void Function(int chunkSize) onChunk,
  }) async {
    await _readLoop(byteCount, (chunk) {
      sink.add(chunk);
      onChunk(chunk.length);
    });
  }

  Future<void> _readLoop(
    int byteCount,
    void Function(List<int> chunk) onChunk,
  ) async {
    var remaining = byteCount;
    while (remaining > 0) {
      if (_offset >= _buffer.length) {
        final hasNext = await _iterator.moveNext();
        if (!hasNext) {
          throw const SocketException('Socket closed before transfer completed');
        }
        _buffer = _iterator.current;
        _offset = 0;
      }
      final available = _buffer.length - _offset;
      final take = math.min(
        AppConstants.socketChunkSize,
        math.min(available, remaining),
      );
      onChunk(_buffer.sublist(_offset, _offset + take));
      _offset += take;
      remaining -= take;
    }
  }
}
