enum TransferPhase {
  idle,
  preparing,
  waitingForPeer,
  transferring,
  completed,
  failed,
}

class TransferProgress {
  const TransferProgress({
    required this.phase,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.startedAt,
    this.currentFileName,
    this.errorMessage,
  });

  final TransferPhase phase;
  final int bytesTransferred;
  final int totalBytes;
  final DateTime? startedAt;
  final String? currentFileName;
  final String? errorMessage;

  static const idle = TransferProgress(
    phase: TransferPhase.idle,
    bytesTransferred: 0,
    totalBytes: 0,
    startedAt: null,
  );

  double get fraction {
    if (totalBytes <= 0) {
      return 0;
    }
    return (bytesTransferred / totalBytes).clamp(0, 1);
  }

  double get bytesPerSecond {
    final start = startedAt;
    if (start == null || bytesTransferred == 0) {
      return 0;
    }
    final elapsedMs = DateTime.now().difference(start).inMilliseconds;
    if (elapsedMs <= 0) {
      return 0;
    }
    return bytesTransferred / (elapsedMs / 1000);
  }

  Duration? get eta {
    final speed = bytesPerSecond;
    if (speed <= 0 || totalBytes <= 0) {
      return null;
    }
    final remaining = totalBytes - bytesTransferred;
    if (remaining <= 0) {
      return Duration.zero;
    }
    return Duration(seconds: (remaining / speed).ceil());
  }

  TransferProgress copyWith({
    TransferPhase? phase,
    int? bytesTransferred,
    int? totalBytes,
    DateTime? startedAt,
    String? currentFileName,
    String? errorMessage,
  }) {
    return TransferProgress(
      phase: phase ?? this.phase,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      startedAt: startedAt ?? this.startedAt,
      currentFileName: currentFileName ?? this.currentFileName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

