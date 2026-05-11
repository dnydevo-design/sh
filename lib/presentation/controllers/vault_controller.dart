import 'package:flutter/material.dart';

import '../../data/services/vault_service.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/vault_record.dart';

class VaultController extends ChangeNotifier {
  VaultController(this._vaultService);

  final VaultService _vaultService;
  final List<VaultRecord> _records = [];
  bool _isBusy = false;
  String? _lastOutputPath;
  String? _error;

  List<VaultRecord> get records => List.unmodifiable(_records);
  bool get isBusy => _isBusy;
  String? get lastOutputPath => _lastOutputPath;
  String? get error => _error;

  Future<void> encryptSelected({
    required List<TransferFile> files,
    required String password,
  }) async {
    if (files.isEmpty || password.isEmpty) {
      return;
    }
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      for (final file in files) {
        _records.insert(
          0,
          await _vaultService.encryptFile(file: file, password: password),
        );
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> decrypt({
    required VaultRecord record,
    required String password,
  }) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      final file = await _vaultService.decryptFile(
        record: record,
        password: password,
      );
      _lastOutputPath = file.path;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}

