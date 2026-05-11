import '../enums/file_category.dart';
import 'ai_classification.dart';

class TransferFile {
  const TransferFile({
    required this.id,
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.category,
    this.classification = AiClassification.unknown,
  });

  final String id;
  final String path;
  final String name;
  final int sizeBytes;
  final FileCategory category;
  final AiClassification classification;

  TransferFile copyWith({
    String? id,
    String? path,
    String? name,
    int? sizeBytes,
    FileCategory? category,
    AiClassification? classification,
  }) {
    return TransferFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      category: category ?? this.category,
      classification: classification ?? this.classification,
    );
  }

  Map<String, Object?> toManifestJson() {
    return {
      'id': id,
      'name': name,
      'sizeBytes': sizeBytes,
      'category': category.name,
      'classification': classification.label,
      'chunkBytes': 64 * 1024,
    };
  }

  static TransferFile fromManifestJson(Map<String, Object?> json, String path) {
    final categoryName = json['category'] as String? ?? FileCategory.other.name;
    return TransferFile(
      id: json['id'] as String? ?? path,
      path: path,
      name: json['name'] as String? ?? path.split('/').last,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      category: FileCategory.values.firstWhere(
        (category) => category.name == categoryName,
        orElse: () => FileCategory.other,
      ),
      classification: AiClassification(
        label: json['classification'] as String? ?? 'Received file',
        confidence: 1,
        tags: const ['received'],
        cleanupScore: 0,
      ),
    );
  }
}
