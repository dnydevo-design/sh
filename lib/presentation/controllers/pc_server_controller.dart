import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/pc_http_server_service.dart';
import '../../domain/entities/pc_share_session.dart';
import '../../domain/entities/transfer_file.dart';

class PcServerController extends ChangeNotifier {
  PcServerController(this._serverService);

  final PcHttpServerService _serverService;
  PcShareSession? _session;
  bool _isStarting = false;

  PcShareSession? get session => _session;
  bool get isStarting => _isStarting;

  Future<void> start(List<TransferFile> files) async {
    if (files.isEmpty) {
      return;
    }
    _isStarting = true;
    notifyListeners();
    _session = await _serverService.start(files);
    _isStarting = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _serverService.stop();
    _session = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_serverService.stop());
    super.dispose();
  }
}
