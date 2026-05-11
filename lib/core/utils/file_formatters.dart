import 'dart:math' as math;

String formatBytes(num bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final index = math.min(
    (math.log(bytes) / math.log(1024)).floor(),
    suffixes.length - 1,
  );
  final value = bytes / math.pow(1024, index);
  final decimals = value == value.roundToDouble() || value >= 10 || index == 0
      ? 0
      : 1;
  return '${value.toStringAsFixed(decimals)} ${suffixes[index]}';
}

String formatSpeed(double bytesPerSecond) {
  return '${formatBytes(bytesPerSecond)}/s';
}

String formatDuration(Duration? duration) {
  if (duration == null || duration.isNegative) {
    return '--';
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
