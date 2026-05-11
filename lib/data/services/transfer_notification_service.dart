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
    
    // تم التعديل هنا: إضافة اسم المعامل initializationSettings
    await _plugin.initialize(initializationSettings: settings);
    _initialized = true;
  }

  Future<void> showTransfer(TransferProgress progress) async {
    await initialize();
    final percent = (progress.fraction * 100).round().clamp(0, 100).toInt();
    
    // تم التعديل هنا: تحويل جميع القيم إلى Named Parameters
    await _plugin.show(
      1001, // الـ ID يبقى كما هو كـ positional
      'Fast Share',
      progress.currentFileName ?? progress.phase.name,
      notificationDetails: NotificationDetails(
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

  // تم التعديل هنا: دالة الـ cancel في الإصدارات الجديدة
  Future<void> clearTransfer() => _plugin.cancel(id: 1001);
}
