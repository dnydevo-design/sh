import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/transfer_progress.dart';

class TransferNotificationService {
  TransferNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('launch_icon'),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showTransfer(TransferProgress progress) async {
    await initialize();
    final percent = (progress.fraction * 100).round().clamp(0, 100).toInt();
    await _plugin.show(
      1001,
      'Fast Share',
      progress.currentFileName ?? progress.phase.name,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fast_share_transfers',
          'Fast Share transfers',
          channelDescription: 'Background transfer progress',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: progress.phase == TransferPhase.transferring,
          showProgress: true,
          maxProgress: 100,
          progress: percent,
        ),
      ),
    );
  }

  Future<void> clearTransfer() => _plugin.cancel(1001);
}
