import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/l10n_extension.dart';
import '../controllers/profile_controller.dart';
import '../widgets/glass_panel.dart';
import 'qr_scanner_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final trusted = context.watch<ProfileController>().trustedDevices;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('profile'))),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (profile != null)
            GlassPanel(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36.r,
                    child: Text(profile.initials),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    profile.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    color: Colors.white,
                    child: QrImageView(
                      data: profile.toFastIdPayload(),
                      size: 220.w,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(l10n.t('fast_id')),
                ],
              ),
            ),
          SizedBox(height: 12.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('trusted_devices'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 8.h),
                if (trusted.isEmpty)
                  Text(l10n.t('idle'))
                else
                  for (final device in trusted)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(device.username[0])),
                      title: Text(device.username),
                      subtitle: Text(device.pairedAt.toLocal().toString()),
                    ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: Text(l10n.t('scan_qr')),
                    onPressed: () async {
                      final payload = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (_) => const QrScannerScreen(),
                        ),
                      );
                      if (payload != null && context.mounted) {
                        await context
                            .read<ProfileController>()
                            .trustFastId(payload);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
