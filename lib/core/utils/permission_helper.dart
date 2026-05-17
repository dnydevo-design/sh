import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// يطلب جميع الصلاحيات اللازمة لعمل مكتبة nearby_connections بشكل صحيح
  /// يعالج مشكلة التعليق ويقوم بتوجيه المستخدم للإعدادات إذا رفض الصلاحيات نهائياً
  static Future<bool> requestNearbyPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      // 1. التأكد من تفعيل خدمة الموقع (Location Services)
      // المكتبة تتطلب تفعيل الموقع فعلياً في الجهاز للبحث عن الأجهزة (في إصدارات أندرويد القديمة)
      bool isLocationEnabled = await Nearby().checkLocationEnabled();
      if (!isLocationEnabled) {
        // سيظهر نافذة من النظام لتفعيل الموقع
        await Nearby().enableLocationServices();
        // ننتظر قليلاً لضمان تفاعل المستخدم
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 2. قائمة الصلاحيات المطلوبة
      // تشمل الموقع وصلاحيات البلوتوث الجديدة في أندرويد 12+
      List<Permission> permissions = [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ];

      // طلب الصلاحيات دفعة واحدة (هذا يمنع تعليق شاشة الطلب المتكرر)
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = true;
      bool isPermanentlyDenied = false;

      for (var permission in permissions) {
        final status = statuses[permission];
        
        // التحقق من حالة كل صلاحية
        if (status?.isPermanentlyDenied == true) {
          isPermanentlyDenied = true;
        }
        
        // بعض الصلاحيات قد لا تكون متوفرة في إصدارات أندرويد القديمة وتعود كـ restricted
        if (status != PermissionStatus.granted && status != PermissionStatus.restricted) {
          allGranted = false;
        }
      }

      // 3. توجيه المستخدم للإعدادات في حال الرفض النهائي
      if (isPermanentlyDenied) {
        if (context.mounted) {
          _showSettingsDialog(context);
        }
        return false;
      }

      return allGranted;
    } catch (e) {
      debugPrint("Permission request error: $e");
      return false;
    }
  }

  /// نافذة تنبيه تظهر للمستخدم تطلب منه تفعيل الصلاحيات من الإعدادات
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('صلاحيات مطلوبة', textAlign: TextAlign.right),
        content: const Text(
          'لكي يعمل النقل السريع (Fast Share) بنجاح، نحتاج إلى صلاحيات البلوتوث والموقع للبحث عن الأجهزة القريبة والاتصال بها.\n\nالرجاء تفعيلها من إعدادات التطبيق.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // يفتح إعدادات التطبيق مباشرة
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
}
