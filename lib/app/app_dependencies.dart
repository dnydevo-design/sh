import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/clipboard_sync_service.dart';
import '../data/services/compression_service.dart';
import '../data/services/file_picker_service.dart';
import '../data/services/nearby_connectivity_service.dart';
import '../data/services/network_address_service.dart';
import '../data/services/offline_chat_service.dart';
import '../data/services/pc_http_server_service.dart';
import '../data/services/permission_service.dart';
import '../data/services/profile_service.dart';
import '../data/services/remote_camera_service.dart';
import '../data/services/scheduled_transfer_service.dart';
import '../data/services/shake_detection_service.dart';
import '../data/services/smart_classifier_service.dart';
import '../data/services/socket_transfer_service.dart';
import '../data/services/transfer_notification_service.dart';
import '../data/services/vault_service.dart';

class AppDependencies {
  AppDependencies(this.preferences)
      : permissionService = const PermissionService(),
        filePickerService = const FilePickerService(),
        smartClassifierService = const SmartClassifierService(),
        networkAddressService = const NetworkAddressService(),
        compressionService = const CompressionService(),
        clipboardSyncService = const ClipboardSyncService(),
        vaultService = VaultService(),
        offlineChatService = OfflineChatService(),
        shakeDetectionService = ShakeDetectionService(),
        transferNotificationService = TransferNotificationService(),
        remoteCameraService = RemoteCameraService(),
        nearbyConnectivityService = NearbyConnectivityService() {
    socketTransferService = SocketTransferService(networkAddressService);
    pcHttpServerService = PcHttpServerService(networkAddressService);
    smartCleanupService = SmartCleanupService(smartClassifierService);
    profileService = ProfileService(preferences);
    scheduledTransferService = ScheduledTransferService(preferences);
  }

  final SharedPreferences preferences;
  final PermissionService permissionService;
  final FilePickerService filePickerService;
  final SmartClassifierService smartClassifierService;
  final NetworkAddressService networkAddressService;
  final CompressionService compressionService;
  final ClipboardSyncService clipboardSyncService;
  final VaultService vaultService;
  final OfflineChatService offlineChatService;
  final ShakeDetectionService shakeDetectionService;
  final TransferNotificationService transferNotificationService;
  final RemoteCameraService remoteCameraService;
  final NearbyConnectivityService nearbyConnectivityService;

  late final SocketTransferService socketTransferService;
  late final PcHttpServerService pcHttpServerService;
  late final SmartCleanupService smartCleanupService;
  late final ProfileService profileService;
  late final ScheduledTransferService scheduledTransferService;
}
