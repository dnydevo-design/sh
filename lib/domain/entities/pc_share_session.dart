import 'transfer_file.dart';

class PcShareSession {
  const PcShareSession({
    required this.url,
    required this.files,
    required this.startedAt,
    required this.uploadDirectoryPath,
  });

  final Uri url;
  final List<TransferFile> files;
  final DateTime startedAt;
  final String uploadDirectoryPath;
}
