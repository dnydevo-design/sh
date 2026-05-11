import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/transfer_file.dart';
import '../../domain/enums/file_category.dart';

class FilePickerService {
  const FilePickerService();

  Future<List<TransferFile>> pick(FileCategory category) async {
    // تم إصلاح الاستدعاء هنا ليتوافق مع الإصدارات الحديثة
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: _fileTypeFor(category),
      allowedExtensions: _allowedExtensionsFor(category),
      withData: false,
      lockParentWindow: true,
    );

    if (result == null) {
      return [];
    }

    final files = <TransferFile>[];
    for (final platformFile in result.files) {
      final path = platformFile.path;
      if (path == null) {
        continue;
      }
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      final stat = await file.stat();
      final resolvedCategory = category == FileCategory.other
          ? fileCategoryFromPath(path)
          : category;
      
      // تأكد أن idSeed فريد بناءً على خصائص الملف
      final idSeed = '$path:${stat.size}:${stat.modified.toIso8601String()}';
      
      files.add(
        TransferFile(
          id: sha1.convert(utf8.encode(idSeed)).toString(),
          path: path,
          name: platformFile.name,
          sizeBytes: stat.size,
          category: resolvedCategory,
        ),
      );
    }
    return files;
  }

  FileType _fileTypeFor(FileCategory category) {
    return switch (category) {
      FileCategory.photos => FileType.image,
      FileCategory.videos => FileType.video,
      FileCategory.other => FileType.any,
      _ => FileType.custom,
    };
  }

  List<String>? _allowedExtensionsFor(FileCategory category) {
    return switch (category) {
      FileCategory.apps ||
      FileCategory.docs ||
      FileCategory.archives => category.allowedExtensions,
      _ => null,
    };
  }
}
