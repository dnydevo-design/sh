import 'transfer_file.dart';

class PreviewManifest {
  const PreviewManifest({
    required this.senderName,
    required this.files,
    required this.totalBytes,
    required this.createdAt,
  });

  final String senderName;
  final List<TransferFile> files;
  final int totalBytes;
  final DateTime createdAt;
}

