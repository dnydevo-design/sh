import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/vault_record.dart';

class VaultService {
  VaultService({AesGcm? algorithm})
      : _algorithm = algorithm ?? AesGcm.with256bits();

  static const _magic = 'FSVAULT1';
  final AesGcm _algorithm;

  Future<VaultRecord> encryptFile({
    required TransferFile file,
    required String password,
  }) async {
    final source = File(file.path);
    final vaultDir = await _vaultDirectory();
    final encryptedPath = p.join(
      vaultDir.path,
      '${file.name}.${DateTime.now().millisecondsSinceEpoch}.fsvault',
    );
    final sink = File(encryptedPath).openWrite();
    final salt = _secureBytes(16);
    final key = SecretKey(_deriveKey(password, salt));
    var encryptedBytes = 0;

    final header = utf8.encode(jsonEncode({
      'magic': _magic,
      'name': file.name,
      'sizeBytes': file.sizeBytes,
      'salt': base64Encode(salt),
      'createdAt': DateTime.now().toIso8601String(),
    }));
    sink.add(_uint32(header.length));
    sink.add(header);

    await for (final chunk in source.openRead().transform(_chunker())) {
      final nonce = _secureBytes(12);
      final box = await _algorithm.encrypt(
        chunk,
        secretKey: key,
        nonce: nonce,
      );
      sink
        ..add([nonce.length])
        ..add([box.mac.bytes.length])
        ..add(_uint32(box.cipherText.length))
        ..add(_uint32(chunk.length))
        ..add(nonce)
        ..add(box.mac.bytes)
        ..add(box.cipherText);
      encryptedBytes +=
          10 + nonce.length + box.mac.bytes.length + box.cipherText.length;
    }
    await sink.flush();
    await sink.close();

    return VaultRecord(
      id: sha256.convert(utf8.encode(encryptedPath)).toString(),
      name: file.name,
      path: encryptedPath,
      originalSizeBytes: file.sizeBytes,
      encryptedSizeBytes: encryptedBytes,
      createdAt: DateTime.now(),
    );
  }

  Future<File> decryptFile({
    required VaultRecord record,
    required String password,
    Directory? outputDirectory,
  }) async {
    final source = File(record.path);
    final reader = _FileByteReader(await source.open());
    final headerLength = _readUint32(await reader.readExact(4));
    final header = jsonDecode(utf8.decode(await reader.readExact(headerLength)))
        as Map<String, Object?>;
    if (header['magic'] != _magic) {
      throw const FormatException('Invalid Fast Share vault file');
    }

    final salt = base64Decode(header['salt'] as String);
    final key = SecretKey(_deriveKey(password, salt));
    final outDir = outputDirectory ?? await getApplicationDocumentsDirectory();
    final output = File(p.join(outDir.path, header['name'] as String));
    final sink = output.openWrite();

    while (!await reader.isAtEnd) {
      final nonceLength = await reader.readByteOrNull();
      if (nonceLength == null) {
        break;
      }
      final macLength = await reader.readByte();
      final cipherLength = _readUint32(await reader.readExact(4));
      await reader.readExact(4);
      final nonce = await reader.readExact(nonceLength);
      final mac = await reader.readExact(macLength);
      final cipherText = await reader.readExact(cipherLength);
      final clear = await _algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      sink.add(clear);
    }

    await sink.flush();
    await sink.close();
    await reader.close();
    return output;
  }

  Future<Directory> _vaultDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    return Directory(p.join(root.path, 'Fast Share Vault')).create(recursive: true);
  }

  List<int> _deriveKey(String password, List<int> salt) {
    var digest = sha256.convert([...utf8.encode(password), ...salt]).bytes;
    for (var i = 0; i < 60000; i++) {
      digest = sha256.convert([...digest, ...salt, ...utf8.encode(password)]).bytes;
    }
    return digest;
  }

  List<int> _secureBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  StreamTransformer<List<int>, List<int>> _chunker() {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        var offset = 0;
        while (offset < data.length) {
          final end = min(offset + AppConstants.socketChunkSize, data.length);
          sink.add(data.sublist(offset, end));
          offset = end;
        }
      },
    );
  }

  List<int> _uint32(int value) {
    return (ByteData(4)..setUint32(0, value)).buffer.asUint8List();
  }

  int _readUint32(List<int> bytes) {
    return ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0);
  }
}

class _FileByteReader {
  _FileByteReader(this._file);

  final RandomAccessFile _file;

  Future<bool> get isAtEnd async => await _file.position() >= await _file.length();

  Future<List<int>> readExact(int count) async {
    final bytes = await _file.read(count);
    if (bytes.length != count) {
      throw const FormatException('Unexpected end of vault file');
    }
    return bytes;
  }

  Future<int?> readByteOrNull() async {
    if (await isAtEnd) {
      return null;
    }
    return readByte();
  }

  Future<int> readByte() async {
    final bytes = await readExact(1);
    return bytes.first;
  }

  Future<void> close() => _file.close();
}
