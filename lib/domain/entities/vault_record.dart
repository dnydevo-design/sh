class VaultRecord {
  const VaultRecord({
    required this.id,
    required this.name,
    required this.path,
    required this.originalSizeBytes,
    required this.encryptedSizeBytes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String path;
  final int originalSizeBytes;
  final int encryptedSizeBytes;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'originalSizeBytes': originalSizeBytes,
      'encryptedSizeBytes': encryptedSizeBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static VaultRecord fromJson(Map<String, Object?> json) {
    return VaultRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      originalSizeBytes: (json['originalSizeBytes'] as num?)?.toInt() ?? 0,
      encryptedSizeBytes: (json['encryptedSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

