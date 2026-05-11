enum ChatMessageDirection {
  outgoing,
  incoming,
  system,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.direction,
  });

  final String id;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final ChatMessageDirection direction;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'direction': direction.name,
    };
  }

  static ChatMessage fromJson(Map<String, Object?> json) {
    final directionName =
        json['direction'] as String? ?? ChatMessageDirection.incoming.name;
    return ChatMessage(
      id: json['id'] as String,
      senderName: json['senderName'] as String? ?? 'Peer',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      direction: ChatMessageDirection.values.firstWhere(
        (direction) => direction.name == directionName,
        orElse: () => ChatMessageDirection.incoming,
      ),
    );
  }
}

