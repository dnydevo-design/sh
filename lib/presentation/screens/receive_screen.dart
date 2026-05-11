import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/glass_panel.dart';
import 'qr_scanner_screen.dart';
import 'transfer_dashboard_screen.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: AppTheme.electricBlue, size: 42.sp),
              SizedBox(height: 16.h),
              Text(
                l10n.t('receive'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 8.h),
              Text(l10n.t('camera_body')),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(l10n.t('scan_qr')),
                  onPressed: () async {
                    final payload = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                    );
                    if (payload == null || !context.mounted) {
                      return;
                    }
                    final controller = context.read<TransferController>();
                    unawaited(controller.receiveFromQr(payload));
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransferDashboardScreen(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

