import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/pc_share_session.dart';
import '../../domain/entities/transfer_file.dart';
import 'network_address_service.dart';

class PcHttpServerService {
  PcHttpServerService(this._networkAddressService);

  final NetworkAddressService _networkAddressService;
  HttpServer? _server;
  List<TransferFile> _files = const [];
  Directory? _uploadDirectory;

  Future<PcShareSession> start(List<TransferFile> files) async {
    await stop();
    _files = List.unmodifiable(files);
    _uploadDirectory = await _ensureUploadDirectory();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    unawaited(_server!.forEach(_handleRequest));
    final host = await _networkAddressService.preferredIPv4Address();
    return PcShareSession(
      url: Uri.parse('http://$host:${_server!.port}/'),
      files: _files,
      startedAt: DateTime.now(),
      uploadDirectoryPath: _uploadDirectory!.path,
    );
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _files = const [];
    await server?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    // تم استخدام النص المباشر للهيدر لضمان التوافق
    response.headers.set('Access-Control-Allow-Origin', '*');

    try {
      if (request.uri.path == '/') {
        response.headers.contentType = ContentType.html;
        response.write(_indexHtml());
        await response.close();
        return;
      }

      if (request.method == 'POST' && request.uri.path == '/upload') {
        final uploaded = await _handleUpload(request);
        response.headers.contentType = ContentType.html;
        response.write(
          '<html><body style="background:#000;color:#fff;font-family:system-ui">'
          '<main style="max-width:680px;margin:40px auto">'
          '<h1>Fast Share</h1><p>Uploaded $uploaded file(s).</p>'
          '<p><a style="color:#00e5ff" href="/">Back</a></p></main></body></html>',
        );
        await response.close();
        return;
      }

      if (request.uri.pathSegments.length == 2 &&
          request.uri.pathSegments.first == 'download') {
        final id = Uri.decodeComponent(request.uri.pathSegments.last);
        TransferFile? file;
        for (final candidate in _files) {
          if (candidate.id == id) {
            file = candidate;
            break;
          }
        }
        if (file == null) {
          response.statusCode = HttpStatus.notFound;
          response.write('File not found');
          await response.close();
          return;
        }
        final source = File(file.path);
        if (!await source.exists()) {
          response.statusCode = HttpStatus.notFound;
          response.write('Source file missing');
          await response.close();
          return;
        }

        response.headers
          ..contentType = ContentType.parse(
            lookupMimeType(file.path) ?? 'application/octet-stream',
          )
          ..set(
            'content-disposition', // تم التغيير لنص مباشر لتجنب الخطأ
            'attachment; filename="${_escapeHeader(file.name)}"',
          )
          ..set('content-length', file.sizeBytes.toString());
        await response.addStream(source.openRead());
        await response.close();
        return;
      }

      response.statusCode = HttpStatus.notFound;
      response.write('Not found');
      await response.close();
    } catch (error) {
      response.statusCode = HttpStatus.internalServerError;
      response.write(error.toString());
      await response.close();
    }
  }

  String _indexHtml() {
    final rows = _files
        .map(
          (file) =>
              '<li><a href="/download/${Uri.encodeComponent(file.id)}">${htmlEscape.convert(file.name)}</a></li>',
        )
        .join();
    return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Fast Share</title>
  <style>
    body { margin: 0; font-family: system-ui, sans-serif; background: #000; color: white; }
    main { max-width: 760px; margin: 0 auto; padding: 48px 20px; }
    h1 { font-size: 40px; margin: 0 0 8px; }
    p { color: #aab4c4; }
    form { margin: 24px 0; padding: 18px; border: 1px solid #1f2937; border-radius: 8px; background: #0a0d12; }
    button { background: linear-gradient(90deg,#00e5ff,#ff2bd6); border: 0; border-radius: 8px; padding: 12px 16px; font-weight: 800; color: #000; }
    li { margin: 12px 0; padding: 14px; border: 1px solid #1f2937; border-radius: 8px; list-style: none; background: #0a0d12; }
    a { color: #00e5ff; text-decoration: none; font-weight: 700; }
  </style>
</head>
<body>
  <main>
    <h1>Fast Share</h1>
    <p>Download files from this phone, or drop files back to mobile over the same local network.</p>
    <form action="/upload" method="post" enctype="multipart/form-data">
      <p>Web Drop: PC to Mobile</p>
      <input type="file" name="files" multiple>
      <button type="submit">Upload to phone</button>
    </form>
    <ul>$rows</ul>
  </main>
</body>
</html>
''';
  }

  String _escapeHeader(String value) {
    return value.replaceAll('"', "'");
  }

  Future<int> _handleUpload(HttpRequest request) async {
    final contentType = request.headers.contentType;
    final boundary = contentType?.parameters['boundary'];
    if (boundary == null) {
      throw const FormatException('Missing multipart boundary');
    }
    final uploadDirectory = _uploadDirectory ?? await _ensureUploadDirectory();
    var count = 0;
    final parts = MimeMultipartTransformer(boundary).bind(request);
    await for (final part in parts) {
      // الحل النهائي لخطأ contentDispositionHeader:
      final disposition = part.headers['content-disposition'];
      if (disposition == null) {
        continue;
      }
      final parsed = HeaderValue.parse(disposition);
      final rawName = parsed.parameters['filename'];
      if (rawName == null || rawName.isEmpty) {
        continue;
      }
      final fileName = rawName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File(p.join(uploadDirectory.path, fileName));
      final sink = file.openWrite();
      await sink.addStream(part);
      await sink.flush();
      await sink.close();
      count++;
    }
    return count;
  }

  Future<Directory> _ensureUploadDirectory() async {
    Directory root;
    if (Platform.isAndroid) {
      root = Directory('/storage/emulated/0/Download/Fast Share/Web Drop');
      try {
        if (!await root.exists()) {
          await root.create(recursive: true);
        }
        return root;
      } catch (_) {
        final fallback = await getExternalStorageDirectory();
        root = Directory(p.join(fallback!.path, 'Web Drop'));
      }
    } else {
      root = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'Web Drop'),
      );
    }
    return root.create(recursive: true);
  }
}
