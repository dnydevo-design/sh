enum FileCategory {
  apps,
  videos,
  photos,
  docs,
  archives,
  other,
}

extension FileCategoryX on FileCategory {
  String get labelKey {
    return switch (this) {
      FileCategory.apps => 'apps',
      FileCategory.videos => 'videos',
      FileCategory.photos => 'photos',
      FileCategory.docs => 'docs',
      FileCategory.archives => 'archives',
      FileCategory.other => 'other',
    };
  }

  List<String> get allowedExtensions {
    return switch (this) {
      FileCategory.apps => ['apk', 'aab', 'xapk'],
      FileCategory.videos => ['mp4', 'mkv', 'mov', 'avi', 'webm', '3gp'],
      FileCategory.photos => ['jpg', 'jpeg', 'png', 'webp', 'heic', 'gif'],
      FileCategory.docs => [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'csv',
        ],
      FileCategory.archives => ['zip', 'rar', '7z', 'tar', 'gz'],
      FileCategory.other => [],
    };
  }

}

FileCategory fileCategoryFromPath(String path) {
  final extension = path.split('.').last.toLowerCase();
  for (final category in FileCategory.values) {
    if (category.allowedExtensions.contains(extension)) {
      return category;
    }
  }
  return FileCategory.other;
}
