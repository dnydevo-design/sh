import 'transfer_file.dart';

enum CleanupReason {
  largeTransferred,
  installer,
  archive,
  duplicateName,
}

class CleanupSuggestion {
  const CleanupSuggestion({
    required this.id,
    required this.file,
    required this.reason,
    required this.score,
    required this.message,
  });

  final String id;
  final TransferFile file;
  final CleanupReason reason;
  final double score;
  final String message;
}

