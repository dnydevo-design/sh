import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/services/nearby_connectivity_service.dart';
import '../../data/services/socket_transfer_service.dart';
import '../../data/services/transfer_notification_service.dart';
import '../../domain/entities/peer_invite.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/transfer_progress.dart';

class TransferController extends ChangeNotifier {
  TransferController(
    this._socketTransferService,
    this._nearbyService,
    this._notificationService,
  );

  final SocketTransferService _socketTransferService;
  final NearbyConnectivityService _nearbyService;
  final TransferNotificationService _notificationService;

  TransferProgress _progress = TransferProgress.idle;
  PeerInvite? _invite;
  OutgoingSocketSession? _outgoingSession;
  List<TransferFile> _completedFiles = const [];
  DateTime _lastNotificationAt = DateTime.fromMillisecondsSinceEpoch(0);

  TransferProgress get progress => _progress;
  PeerInvite? get invite => _invite;
  List<TransferFile> get completedFiles => List.unmodifiable(_completedFiles);

  Future<void> prepareSend(
    List<TransferFile> files, {
    required String endpointName,
  }) async {
    if (files.isEmpty) {
      return;
    }
    await _outgoingSession?.dispose();
    _progress = TransferProgress(
      phase: TransferPhase.preparing,
      bytesTransferred: 0,
      totalBytes: files.fold(0, (sum, file) => sum + file.sizeBytes),
      startedAt: null,
    );
    notifyListeners();

    final nearbyReady = await _nearbyService
        .startAdvertising(
          userName: endpointName,
          onConnectionInitiated: (_, __) {},
          onConnectionResult: (_, __) {},
          onDisconnected: (_) {},
        )
        .timeout(const Duration(seconds: 4), onTimeout: () => false)
        .catchError((_) => false);

    _outgoingSession = await _socketTransferService.hostFiles(
      files: files,
      displayName: endpointName,
      transport: nearbyReady ? PeerTransport.socket : PeerTransport.hotspot,
      onProgress: _setProgress,
    );
    _invite = _outgoingSession!.invite;
    notifyListeners();

    unawaited(
      _outgoingSession!.completion.then((sent) {
        _completedFiles = sent;
        notifyListeners();
      }).catchError((Object error) {
        _setProgress(
          TransferProgress(
            phase: TransferPhase.failed,
            bytesTransferred: _progress.bytesTransferred,
            totalBytes: _progress.totalBytes,
            startedAt: _progress.startedAt,
            errorMessage: error.toString(),
          ),
        );
      }),
    );
  }

  Future<void> receiveFromQr(String payload) async {
    final parsedInvite = PeerInvite.fromQrPayload(payload);
    _invite = parsedInvite;
    _progress = const TransferProgress(
      phase: TransferPhase.preparing,
      bytesTransferred: 0,
      totalBytes: 0,
      startedAt: null,
    );
    notifyListeners();

    try {
      final directory = await _receiveDirectory();
      final files = await _socketTransferService.receive(
        invite: parsedInvite,
        targetDirectory: directory,
        onProgress: _setProgress,
      );
      _completedFiles = files;
      notifyListeners();
    } catch (error) {
      _setProgress(
        TransferProgress(
          phase: TransferPhase.failed,
          bytesTransferred: _progress.bytesTransferred,
          totalBytes: _progress.totalBytes,
          startedAt: _progress.startedAt,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reset() {
    _progress = TransferProgress.idle;
    _invite = null;
    _completedFiles = const [];
    notifyListeners();
  }

  Future<void> disposeSession() async {
    await _outgoingSession?.dispose();
    await _nearbyService.stop();
    _outgoingSession = null;
  }

  @override
  void dispose() {
    unawaited(disposeSession());
    super.dispose();
  }

  void _setProgress(TransferProgress progress) {
    _progress = progress;
    final now = DateTime.now();
    final shouldNotify = progress.phase == TransferPhase.completed ||
        progress.phase == TransferPhase.failed ||
        now.difference(_lastNotificationAt).inMilliseconds > 700;
    if (shouldNotify) {
      _lastNotificationAt = now;
      unawaited(_notificationService.showTransfer(progress));
    }
    notifyListeners();
  }

  Future<Directory> _receiveDirectory() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download/Fast Share');
      try {
        return await directory.create(recursive: true);
      } catch (_) {
        final fallback = await getExternalStorageDirectory();
        return Directory('${fallback!.path}/Fast Share')
            .create(recursive: true);
      }
    }
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return Directory('${downloads.path}/Fast Share').create(recursive: true);
    }
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}/Fast Share').create(recursive: true);
  }
}
