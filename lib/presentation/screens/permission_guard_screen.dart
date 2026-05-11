import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/permission_controller.dart';
import '../widgets/glass_panel.dart';

class PermissionGuardScreen extends StatelessWidget {
  const PermissionGuardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PermissionController>();
    final step = controller.currentStep;
    final status = controller.statusFor(step.kind);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/icon/fast_share_icon.svg',
                  width: 116.w,
                  height: 116.w,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.t('permissions_title'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.t('permissions_subtitle'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 24.h),
              LinearProgressIndicator(
                value: (controller.currentIndex + 1) / controller.steps.length,
                minHeight: 6.h,
                borderRadius: BorderRadius.circular(99),
                color: AppTheme.electricBlue,
              ),
              SizedBox(height: 20.h),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_iconFor(step.kind), color: AppTheme.magenta, size: 32.sp),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.t(step.titleKey),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(l10n.t(step.bodyKey)),
                    if (status != null && !status.isGranted) ...[
                      SizedBox(height: 12.h),
                      Text(
                        status.isPermanentlyDenied
                            ? l10n.t('open_settings')
                            : l10n.t('retry'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: controller.isRequesting
                      ? SizedBox.square(
                          dimension: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_rounded),
                  label: Text(l10n.t('grant_permission')),
                  onPressed: controller.isRequesting
                      ? null
                      : () {
                          if (status?.isPermanentlyDenied ?? false) {
                            controller.openSettings();
                          } else {
                            controller.requestCurrent();
                          }
                        },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(Object kind) {
    final name = kind.toString();
    if (name.contains('storage')) return Icons.folder_rounded;
    if (name.contains('location')) return Icons.location_on_rounded;
    if (name.contains('bluetooth')) return Icons.bluetooth_rounded;
    return Icons.qr_code_scanner_rounded;
  }
}
