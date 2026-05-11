import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/entities/chat_message.dart';

class OfflineChatService {
  final _messages = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get messages => _messages.stream;

  ChatMessage localMessage({
    required String senderName,
    required String text,
  }) {
    final message = ChatMessage(
      id: sha1.convert(utf8.encode('$senderName:$text:${DateTime.now()}')).toString(),
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
      direction: ChatMessageDirection.outgoing,
    );
    _messages.add(message);
    return message;
  }

  void receivePayload(List<int> payload) {
    final map = jsonDecode(utf8.decode(payload)) as Map<String, Object?>;
    _messages.add(ChatMessage.fromJson(map));
  }

  List<int> encode(ChatMessage message) {
    return utf8.encode(jsonEncode(message.toJson()));
  }

  void dispose() {
    _messages.close();
  }
}

