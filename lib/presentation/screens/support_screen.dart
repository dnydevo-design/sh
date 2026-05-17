import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/ad_controller.dart';
import '../widgets/glass_panel.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ad = context.watch<AdController>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.trueBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.trueBlack,
        title: Text(l10n.t('support')),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Supporter badge
          if (ad.isSupporter) ...[
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.electricBlue, AppTheme.magenta],
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.t('supporter_badge'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Orange Cash Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF8F00),
                  Color(0xFFFF6D00),
                  Color(0xFFE65100),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonOrange.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 28.sp),
                    SizedBox(width: 10.w),
                    Text(
                      l10n.t('orange_cash'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    AppConstants.supportPhoneNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _OrangeButton(
                        icon: Icons.copy_rounded,
                        label: l10n.t('copy_number'),
                        onTap: () {
                          Clipboard.setData(
                            const ClipboardData(text: AppConstants.supportPhoneNumber),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.t('copied')),
                              backgroundColor: AppTheme.neonOrange,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _OrangeButton(
                        icon: Icons.phone_rounded,
                        label: l10n.t('call_transfer'),
                        onTap: () async {
                          final uri = Uri.parse('tel:${AppConstants.supportPhoneNumber}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Ad Support Card
          GlassPanel(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.electricBlue.withValues(alpha: 0.2),
                        AppTheme.magenta.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.magenta,
                    size: 36.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.t('support_abdullah'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: ad.isAdLoading
                        ? SizedBox.square(
                            dimension: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.play_circle_filled_rounded),
                    label: Text(l10n.t('watch_ad')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.magenta,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: (ad.isAdShowing || ad.isAdLoading)
                        ? null
                        : () => ad.watchSupportAd(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Feature unlock cards
          _FeatureUnlockCard(
            icon: Icons.bolt_rounded,
            title: l10n.t('ultra_speed'),
            isUnlocked: ad.isUltraSpeedUnlocked,
            isLoading: ad.isAdShowing,
            onUnlock: () => ad.unlockFeature(UnlockableFeature.ultraSpeed),
            l10n: l10n,
          ),
          SizedBox(height: 12.h),
          _FeatureUnlockCard(
            icon: Icons.archive_rounded,
            title: l10n.t('fast_zip'),
            isUnlocked: ad.isFastZipUnlocked,
            isLoading: ad.isAdShowing,
            onUnlock: () => ad.unlockFeature(UnlockableFeature.fastZip),
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _OrangeButton extends StatelessWidget {
  const _OrangeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureUnlockCard extends StatelessWidget {
  const _FeatureUnlockCard({
    required this.icon,
    required this.title,
    required this.isUnlocked,
    required this.isLoading,
    required this.onUnlock,
    required this.l10n,
  });

  final IconData icon;
  final String title;
  final bool isUnlocked;
  final bool isLoading;
  final VoidCallback onUnlock;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppTheme.successGreen.withValues(alpha: 0.2)
                  : AppTheme.electricBlue.withValues(alpha: 0.15),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? AppTheme.successGreen : AppTheme.electricBlue,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isUnlocked
                      ? l10n.t('ad_reward_unlocked')
                      : l10n.t('watch_ad'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isUnlocked
                        ? AppTheme.successGreen
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            IconButton(
              onPressed: isLoading ? null : onUnlock,
              icon: Icon(
                Icons.play_circle_outline_rounded,
                color: AppTheme.magenta,
                size: 32.sp,
              ),
            )
          else
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successGreen,
              size: 28.sp,
            ),
        ],
      ),
    );
  }
}
