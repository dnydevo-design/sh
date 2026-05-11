import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/nearby_connectivity_service.dart';
import '../../data/services/shake_detection_service.dart';
import '../../domain/entities/peer_endpoint.dart';

class RadarController extends ChangeNotifier {
  RadarController(this._nearbyService, this._shakeService);

  final NearbyConnectivityService _nearbyService;
  final ShakeDetectionService _shakeService;
  final List<PeerEndpoint> _endpoints = [];

  bool _isScanning = false;
  bool _incognito = false;
  bool _shakeEnabled = false;

  List<PeerEndpoint> get endpoints => List.unmodifiable(_endpoints);
  bool get isScanning => _isScanning;
  bool get incognito => _incognito;
  bool get shakeEnabled => _shakeEnabled;

  Future<void> start(String endpointName) async {
    if (_incognito) {
      return;
    }
    _isScanning = true;
    _endpoints.clear();
    notifyListeners();
    await _nearbyService.startDiscovery(
      userName: endpointName,
      onEndpointFound: (endpoint) {
        if (_endpoints.every((item) => item.id != endpoint.id)) {
          _endpoints.add(endpoint);
          notifyListeners();
        }
      },
      onEndpointLost: (id) {
        _endpoints.removeWhere((endpoint) => endpoint.id == id);
        notifyListeners();
      },
    ).catchError((_) => false);
  }

  Future<void> advertise(String endpointName) async {
    if (_incognito) {
      return;
    }
    await _nearbyService.startAdvertising(
      userName: endpointName,
      onConnectionInitiated: (_, __) {},
      onConnectionResult: (_, __) {},
      onDisconnected: (_) {},
    ).catchError((_) => false);
  }

  Future<void> stop() async {
    _isScanning = false;
    await _nearbyService.stop();
    notifyListeners();
  }

  Future<void> setIncognito(bool value) async {
    _incognito = value;
    if (value) {
      await stop();
    }
    notifyListeners();
  }

  void setShakeToShare({
    required bool enabled,
    required String endpointName,
  }) {
    _shakeEnabled = enabled;
    if (enabled) {
      _shakeService.start(onShake: () => unawaited(start(endpointName)));
    } else {
      unawaited(_shakeService.stop());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_shakeService.stop());
    unawaited(_nearbyService.stop());
    super.dispose();
  }
}
