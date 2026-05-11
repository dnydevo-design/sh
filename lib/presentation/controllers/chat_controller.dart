import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/clipboard_sync_service.dart';
import '../../data/services/offline_chat_service.dart';
import '../../domain/entities/chat_message.dart';

class ChatController extends ChangeNotifier {
  ChatController(this._chatService, this._clipboardSyncService) {
    _subscription = _chatService.messages.listen((message) {
      _messages.insert(0, message);
      notifyListeners();
    });
  }

  final OfflineChatService _chatService;
  final ClipboardSyncService _clipboardSyncService;
  late final StreamSubscription<ChatMessage> _subscription;
  final List<ChatMessage> _messages = [];
  bool _clipboardSyncEnabled = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get clipboardSyncEnabled => _clipboardSyncEnabled;

  void send({
    required String senderName,
    required String text,
  }) {
    if (text.trim().isEmpty) {
      return;
    }
    _chatService.localMessage(senderName: senderName, text: text.trim());
  }

  Future<void> syncClipboard(String senderName) async {
    if (!_clipboardSyncEnabled) {
      return;
    }
    final text = await _clipboardSyncService.readText();
    if (text == null || text.trim().isEmpty) {
      return;
    }
    send(senderName: senderName, text: text);
  }

  void setClipboardSync(bool value) {
    _clipboardSyncEnabled = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

