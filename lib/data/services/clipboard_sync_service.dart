import 'package:flutter/services.dart';

class ClipboardSyncService {
  const ClipboardSyncService();

  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  Future<void> writeText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}

