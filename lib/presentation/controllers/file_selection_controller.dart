import 'package:flutter/material.dart';

import '../../data/services/file_picker_service.dart';
import '../../data/services/smart_classifier_service.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/enums/file_category.dart';

class FileSelectionController extends ChangeNotifier {
  FileSelectionController(this._filePickerService, this._classifierService);

  final FilePickerService _filePickerService;
  final SmartClassifierService _classifierService;

  final List<TransferFile> _selectedFiles = [];
  FileCategory _category = FileCategory.photos;
  bool _isPicking = false;

  List<TransferFile> get selectedFiles => List.unmodifiable(_selectedFiles);
  FileCategory get category => _category;
  bool get isPicking => _isPicking;
  int get totalBytes =>
      _selectedFiles.fold(0, (sum, file) => sum + file.sizeBytes);

  void setCategory(FileCategory category) {
    _category = category;
    notifyListeners();
  }

  Future<void> pickCurrentCategory() async {
    _isPicking = true;
    notifyListeners();
    final picked = await _filePickerService.pick(_category);
    final classified = await _classifierService.classify(picked);
    for (final file in classified) {
      if (_selectedFiles.every((selected) => selected.id != file.id)) {
        _selectedFiles.add(file);
      }
    }
    _isPicking = false;
    notifyListeners();
  }

  void remove(String id) {
    _selectedFiles.removeWhere((file) => file.id == id);
    notifyListeners();
  }

  void clear() {
    _selectedFiles.clear();
    notifyListeners();
  }
}

