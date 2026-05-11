import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../controllers/profile_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatController>();
    final profile = context.watch<ProfileController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('chat')),
        actions: [
          IconButton(
            tooltip: l10n.t('clipboard_sync'),
            icon: Icon(
              chat.clipboardSyncEnabled
                  ? Icons.content_paste_go_rounded
                  : Icons.content_paste_off_rounded,
            ),
            onPressed: () => chat.setClipboardSync(!chat.clipboardSyncEnabled),
          ),
          IconButton(
            tooltip: l10n.t('send_message'),
            icon: const Icon(Icons.content_paste_go_rounded),
            onPressed: () => chat.syncClipboard(profile.endpointName),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16.w),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                final outgoing = message.direction == ChatMessageDirection.outgoing;
                return Align(
                  alignment:
                      outgoing ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 280.w),
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: outgoing
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: outgoing ? Colors.black : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(labelText: l10n.t('message')),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      chat.send(
                        senderName: profile.endpointName,
                        text: _messageController.text,
                      );
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
