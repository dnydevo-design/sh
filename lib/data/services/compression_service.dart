import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/transfer_file.dart';

class CompressionService {
  const CompressionService();

  Future<File> zipFiles(List<TransferFile> files, {String? name}) async {
    final temp = await getTemporaryDirectory();
    final outPath = p.join(
      temp.path,
      name ?? 'fast-share-${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    final encoder = ZipFileEncoder();
    encoder.create(outPath);
    for (final file in files) {
      final source = File(file.path);
      if (await source.exists()) {
        await encoder.addFile(source, p.basename(file.path));
      }
    }
    await encoder.close();
    return File(outPath);
  }
}
