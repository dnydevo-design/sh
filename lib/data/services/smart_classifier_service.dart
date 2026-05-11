import 'dart:io';

import '../../domain/entities/ai_classification.dart';
import '../../domain/entities/cleanup_suggestion.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/enums/file_category.dart';

class SmartClassifierService {
  const SmartClassifierService();

  Future<List<TransferFile>> classify(List<TransferFile> files) async {
    return [
      for (final file in files)
        file.copyWith(classification: classifyOne(file)),
    ];
  }

  AiClassification classifyOne(TransferFile file) {
    final extension = file.name.split('.').last.toLowerCase();
    final sizeGb = file.sizeBytes / (1024 * 1024 * 1024);
    final tags = <String>[];

    var label = 'General file';
    var confidence = 0.74;
    var cleanupScore = 0.1;

    switch (file.category) {
      case FileCategory.apps:
        label = extension == 'apk' ? 'Android installer' : 'App bundle';
        tags.addAll(['installer', 'portable']);
        confidence = 0.95;
        cleanupScore = 0.82;
      case FileCategory.videos:
        label = sizeGb >= 1 ? 'Large video' : 'Video';
        tags.addAll(['media', 'video']);
        confidence = 0.9;
        cleanupScore = sizeGb >= 1 ? 0.78 : 0.38;
      case FileCategory.photos:
        label = 'Photo collection item';
        tags.addAll(['media', 'photo']);
        confidence = 0.88;
        cleanupScore = file.sizeBytes > 25 * 1024 * 1024 ? 0.42 : 0.18;
      case FileCategory.docs:
        label = 'Document';
        tags.add('document');
        confidence = 0.86;
        cleanupScore = 0.16;
      case FileCategory.archives:
        label = 'Archive package';
        tags.addAll(['archive', 'compressed']);
        confidence = 0.92;
        cleanupScore = 0.68;
      case FileCategory.other:
        label = 'Mixed content';
        tags.add('unknown');
        cleanupScore = file.sizeBytes > 500 * 1024 * 1024 ? 0.45 : 0.08;
    }

    if (_looksLikeDuplicate(file.name)) {
      tags.add('duplicate-name');
      cleanupScore += 0.12;
    }

    return AiClassification(
      label: label,
      confidence: confidence,
      tags: tags,
      cleanupScore: cleanupScore.clamp(0, 1),
    );
  }

  bool _looksLikeDuplicate(String name) {
    final normalized = name.toLowerCase();
    return normalized.contains('(1)') ||
        normalized.contains('copy') ||
        normalized.contains('_copy');
  }
}

class SmartCleanupService {
  const SmartCleanupService(this._classifier);

  final SmartClassifierService _classifier;

  List<CleanupSuggestion> suggest(List<TransferFile> transferredFiles) {
    return transferredFiles
        .map((file) {
          final classification = file.classification == AiClassification.unknown
              ? _classifier.classifyOne(file)
              : file.classification;
          final reason = _reasonFor(file);
          if (classification.cleanupScore < 0.55 && reason == null) {
            return null;
          }
          final resolvedReason = reason ?? CleanupReason.largeTransferred;
          return CleanupSuggestion(
            id: '${file.id}-${resolvedReason.name}',
            file: file.copyWith(classification: classification),
            reason: resolvedReason,
            score: classification.cleanupScore,
            message: _messageFor(file, resolvedReason),
          );
        })
        .whereType<CleanupSuggestion>()
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  Future<void> delete(CleanupSuggestion suggestion) async {
    final file = File(suggestion.file.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  CleanupReason? _reasonFor(TransferFile file) {
    if (file.category == FileCategory.apps) {
      return CleanupReason.installer;
    }
    if (file.category == FileCategory.archives) {
      return CleanupReason.archive;
    }
    if (_classifier.classifyOne(file).tags.contains('duplicate-name')) {
      return CleanupReason.duplicateName;
    }
    if (file.sizeBytes >= 700 * 1024 * 1024) {
      return CleanupReason.largeTransferred;
    }
    return null;
  }

  String _messageFor(TransferFile file, CleanupReason reason) {
    return switch (reason) {
      CleanupReason.installer => 'Installer copied successfully; safe to remove if already installed elsewhere.',
      CleanupReason.archive => 'Archive transferred; delete this copy if the receiver has verified it.',
      CleanupReason.duplicateName => 'Name looks like a duplicate copy.',
      CleanupReason.largeTransferred => 'Large file transferred; deleting it can reclaim storage quickly.',
    };
  }
}

