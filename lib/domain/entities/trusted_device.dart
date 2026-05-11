class TrustedDevice {
  const TrustedDevice({
    required this.id,
    required this.username,
    required this.avatarSeed,
    required this.pairedAt,
  });

  final String id;
  final String username;
  final int avatarSeed;
  final DateTime pairedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarSeed': avatarSeed,
      'pairedAt': pairedAt.toIso8601String(),
    };
  }

  static TrustedDevice fromJson(Map<String, Object?> json) {
    return TrustedDevice(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarSeed: (json['avatarSeed'] as num?)?.toInt() ?? 0,
      pairedAt: DateTime.tryParse(json['pairedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

