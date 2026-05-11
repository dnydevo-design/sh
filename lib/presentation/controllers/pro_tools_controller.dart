import 'package:flutter/material.dart';

import '../../data/services/compression_service.dart';
import '../../data/services/remote_camera_service.dart';
import '../../data/services/scheduled_transfer_service.dart';
import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/trusted_device.dart';

class ProToolsController extends ChangeNotifier {
  ProToolsController(
    this._compressionService,
    this._scheduledTransferService,
    this._remoteCameraService,
  );

  final CompressionService _compressionService;
  final ScheduledTransferService _scheduledTransferService;
  final RemoteCameraService _remoteCameraService;

  List<ScheduledTransfer> _scheduledTransfers = const [];
  bool _isCompressing = false;
  String? _zipPath;
  String? _cameraState;

  List<ScheduledTransfer> get scheduledTransfers =>
      List.unmodifiable(_scheduledTransfers);
  bool get isCompressing => _isCompressing;
  String? get zipPath => _zipPath;
  String? get cameraState => _cameraState;

  void load() {
    _scheduledTransfers = _scheduledTransferService.load();
    notifyListeners();
  }

  Future<void> compress(List<TransferFile> files) async {
    if (files.isEmpty) {
      return;
    }
    _isCompressing = true;
    notifyListeners();
    final zip = await _compressionService.zipFiles(files);
    _zipPath = zip.path;
    _isCompressing = false;
    notifyListeners();
  }

  Future<void> queueForDevice({
    required TrustedDevice device,
    required List<TransferFile> files,
  }) async {
    _scheduledTransfers = await _scheduledTransferService.queue(
      device: device,
      files: files,
    );
    notifyListeners();
  }

  Future<void> startRemoteCamera() async {
    _cameraState = 'Starting camera preview...';
    notifyListeners();
    final controller = await _remoteCameraService.startPreview();
    _cameraState = controller == null
        ? 'No camera available'
        : 'Camera preview ready for trusted receiver handoff';
    notifyListeners();
  }

  Future<void> stopRemoteCamera() async {
    await _remoteCameraService.stop();
    _cameraState = null;
    notifyListeners();
  }
}

