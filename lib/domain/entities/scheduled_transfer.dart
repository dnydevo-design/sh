class ScheduledTransfer {
  const ScheduledTransfer({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.fileIds,
    required this.createdAt,
    this.enabled = true,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final List<String> fileIds;
  final DateTime createdAt;
  final bool enabled;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'fileIds': fileIds,
      'createdAt': createdAt.toIso8601String(),
      'enabled': enabled,
    };
  }

  static ScheduledTransfer fromJson(Map<String, Object?> json) {
    return ScheduledTransfer(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      fileIds: (json['fileIds'] as List<Object?>? ?? const []).cast<String>(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

