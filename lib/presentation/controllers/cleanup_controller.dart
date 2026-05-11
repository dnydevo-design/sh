import 'package:flutter/material.dart';

import '../../data/services/smart_classifier_service.dart';
import '../../domain/entities/cleanup_suggestion.dart';
import '../../domain/entities/transfer_file.dart';

class CleanupController extends ChangeNotifier {
  CleanupController(this._cleanupService);

  final SmartCleanupService _cleanupService;
  final Set<String> _selectedIds = {};
  List<CleanupSuggestion> _suggestions = const [];
  bool _isDeleting = false;

  List<CleanupSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isDeleting => _isDeleting;
  bool isSelected(String id) => _selectedIds.contains(id);

  void buildSuggestions(List<TransferFile> transferredFiles) {
    _suggestions = _cleanupService.suggest(transferredFiles);
    _selectedIds
      ..clear()
      ..addAll(_suggestions.where((s) => s.score >= 0.65).map((s) => s.id));
    notifyListeners();
  }

  void toggle(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    _isDeleting = true;
    notifyListeners();
    final selected = _suggestions.where((s) => _selectedIds.contains(s.id));
    for (final suggestion in selected) {
      await _cleanupService.delete(suggestion);
    }
    _suggestions = _suggestions
        .where((suggestion) => !_selectedIds.contains(suggestion.id))
        .toList();
    _selectedIds.clear();
    _isDeleting = false;
    notifyListeners();
  }
}

