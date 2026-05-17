import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/transfer_file.dart';

class CompressionService {
  const CompressionService();

  /// Compress [files] into a single .zip archive.
  /// [onProgress] is called after each file is added with a value from 0.0 to 1.0.
  Future<File> zipFiles(
    List<TransferFile> files, {
    String? name,
    void Function(double progress)? onProgress,
  }) async {
    final temp = await getTemporaryDirectory();
    final outPath = p.join(
      temp.path,
      name ?? 'fast-share-${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    final encoder = ZipFileEncoder();
    encoder.create(outPath);

    for (var i = 0; i < files.length; i++) {
      final source = File(files[i].path);
      if (await source.exists()) {
        await encoder.addFile(source, p.basename(files[i].path));
      }
      onProgress?.call((i + 1) / files.length);
    }

    await encoder.close();
    return File(outPath);
  }
}
