class AiClassification {
  const AiClassification({
    required this.label,
    required this.confidence,
    required this.tags,
    required this.cleanupScore,
  });

  final String label;
  final double confidence;
  final List<String> tags;
  final double cleanupScore;

  static const unknown = AiClassification(
    label: 'Unclassified',
    confidence: 0,
    tags: [],
    cleanupScore: 0,
  );
}

