import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.avatarSeed,
    required this.createdAt,
  });

  final String id;
  final String username;
  final int avatarSeed;
  final DateTime createdAt;

  String get initials {
    final words = username.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) {
      return 'FS';
    }
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarSeed': avatarSeed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toFastIdPayload() {
    final encoded = base64Url.encode(utf8.encode(jsonEncode(toJson())));
    return 'fastshare://profile/$encoded';
  }

  UserProfile copyWith({
    String? id,
    String? username,
    int? avatarSeed,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static UserProfile fromJson(Map<String, Object?> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarSeed: (json['avatarSeed'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static UserProfile fromFastIdPayload(String payload) {
    final encoded = payload.startsWith('fastshare://profile/')
        ? payload.substring('fastshare://profile/'.length)
        : payload;
    return fromJson(
      jsonDecode(utf8.decode(base64Url.decode(encoded)))
          as Map<String, Object?>,
    );
  }
}

