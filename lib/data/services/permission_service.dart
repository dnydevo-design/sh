import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/permission_step.dart';

class PermissionService {
  const PermissionService();

  Future<bool> isGranted(PermissionKind kind) async {
    if (kind == PermissionKind.storage) {
      return _isStorageGranted();
    }
    final statuses = await Future.wait(_permissionsFor(kind).map((p) => p.status));
    return statuses.every((status) => status.isGranted || status.isLimited);
  }

  Future<PermissionStatus> request(PermissionKind kind) async {
    if (kind == PermissionKind.storage) {
      await Permission.manageExternalStorage.request();
      await [
        Permission.storage,
        Permission.photos,
        Permission.videos,
      ].request();
      return await _isStorageGranted()
          ? PermissionStatus.granted
          : PermissionStatus.denied;
    }
    final permissions = _permissionsFor(kind);
    final statuses = await permissions.request();
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      return PermissionStatus.permanentlyDenied;
    }
    if (statuses.values.every((status) => status.isGranted || status.isLimited)) {
      return PermissionStatus.granted;
    }
    if (statuses.values.any((status) => status.isDenied)) {
      return PermissionStatus.denied;
    }
    return statuses.values.isEmpty ? PermissionStatus.denied : statuses.values.first;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  List<Permission> _permissionsFor(PermissionKind kind) {
    return switch (kind) {
      PermissionKind.storage => [
          Permission.manageExternalStorage,
          Permission.storage,
          Permission.photos,
          Permission.videos,
        ],
      PermissionKind.location => [
          Permission.locationWhenInUse,
        ],
      PermissionKind.bluetooth => [
          Permission.bluetooth,
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.nearbyWifiDevices,
        ],
      PermissionKind.camera => [
          Permission.camera,
        ],
    };
  }

  Future<bool> _isStorageGranted() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    if (await Permission.storage.isGranted) {
      return true;
    }
    final mediaStatuses = await Future.wait([
      Permission.photos.status,
      Permission.videos.status,
    ]);
    return mediaStatuses.every((status) => status.isGranted || status.isLimited);
  }
}
