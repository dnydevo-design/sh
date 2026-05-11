import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../controllers/permission_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/glass_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('theme'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 8.h),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.t('dark')),
                      icon: const Icon(Icons.dark_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.t('light')),
                      icon: const Icon(Icons.light_mode_rounded),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) {
                    settings.setThemeMode(value.first);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 8.h),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.t('english')),
                    ),
                    ButtonSegment(
                      value: 'ar',
                      label: Text(l10n.t('arabic')),
                    ),
                  ],
                  selected: {settings.locale.languageCode},
                  onSelectionChanged: (value) {
                    settings.setLocale(Locale(value.first));
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            icon: const Icon(Icons.verified_user_rounded),
            label: Text(l10n.t('permissions_title')),
            onPressed: () {
              context.read<PermissionController>().reset();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

