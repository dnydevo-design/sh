import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/permission_service.dart';
import '../../domain/entities/permission_step.dart';

class PermissionController extends ChangeNotifier {
  PermissionController(this._permissionService, this._preferences);

  final PermissionService _permissionService;
  final SharedPreferences _preferences;

  final steps = const [
    PermissionStep(
      kind: PermissionKind.storage,
      titleKey: 'storage_title',
      bodyKey: 'storage_body',
    ),
    PermissionStep(
      kind: PermissionKind.location,
      titleKey: 'location_title',
      bodyKey: 'location_body',
    ),
    PermissionStep(
      kind: PermissionKind.bluetooth,
      titleKey: 'bluetooth_title',
      bodyKey: 'bluetooth_body',
    ),
    PermissionStep(
      kind: PermissionKind.camera,
      titleKey: 'camera_title',
      bodyKey: 'camera_body',
    ),
  ];

  var _isLoaded = false;
  var _isComplete = false;
  var _currentIndex = 0;
  var _isRequesting = false;
  final Map<PermissionKind, PermissionStatus> _statuses = {};

  bool get isLoaded => _isLoaded;
  bool get isComplete => _isComplete;
  int get currentIndex => _currentIndex;
  bool get isRequesting => _isRequesting;
  PermissionStep get currentStep => steps[_currentIndex];
  PermissionStatus? statusFor(PermissionKind kind) => _statuses[kind];

  /// Loads permission state. If the onboarding flag is false, performs a live
  /// check of all permissions and Bluetooth state. If everything is already
  /// granted, the permission guard is bypassed entirely. If only some
  /// permissions are granted, the wizard starts at the first missing step.
  Future<void> load() async {
    _isComplete =
        _preferences.getBool(AppConstants.permissionOnboardingKey) ?? false;

    if (!_isComplete) {
      // Live-check all permissions at the OS level
      final allGranted = await _permissionService.areAllPermissionsGranted();
      if (allGranted) {
        // Also verify Bluetooth adapter is enabled
        final btEnabled = await _permissionService.isBluetoothEnabled();
        if (btEnabled) {
          _isComplete = true;
          await _preferences.setBool(
            AppConstants.permissionOnboardingKey,
            true,
          );
        }
      }

      if (!_isComplete) {
        // Find the first permission step that is not yet granted and skip to it
        final statuses = await _permissionService.checkAllStatuses();
        for (var i = 0; i < steps.length; i++) {
          if (statuses[steps[i].kind] != true) {
            _currentIndex = i;
            break;
          }
        }
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> requestCurrent() async {
    _isRequesting = true;
    notifyListeners();
    final status = await _permissionService.request(currentStep.kind);
    _statuses[currentStep.kind] = status;
    _isRequesting = false;

    if (status.isGranted || status.isLimited) {
      await next();
    } else {
      notifyListeners();
    }
  }

  Future<void> next() async {
    if (_currentIndex < steps.length - 1) {
      // Skip to the next un-granted step
      final statuses = await _permissionService.checkAllStatuses();
      var foundPending = false;
      for (var i = _currentIndex + 1; i < steps.length; i++) {
        if (statuses[steps[i].kind] != true) {
          _currentIndex = i;
          foundPending = true;
          break;
        }
      }
      if (!foundPending) {
        // All remaining steps are already granted
        _isComplete = true;
        await _preferences.setBool(AppConstants.permissionOnboardingKey, true);
      }
      notifyListeners();
      return;
    }
    _isComplete = true;
    await _preferences.setBool(AppConstants.permissionOnboardingKey, true);
    notifyListeners();
  }

  Future<void> openSettings() => _permissionService.openSettings();

  Future<void> reset() async {
    _currentIndex = 0;
    _isComplete = false;
    await _preferences.setBool(AppConstants.permissionOnboardingKey, false);
    notifyListeners();
  }
}
