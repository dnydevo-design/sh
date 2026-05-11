import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../controllers/profile_controller.dart';
import '../controllers/radar_controller.dart';
import '../widgets/glass_panel.dart';
import '../widgets/radar_painter.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    final radar = context.watch<RadarController>();
    final profile = context.watch<ProfileController>();
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        SizedBox(
          height: 310.w,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                painter: RadarPainter(
                  sweepRadians: _animation.value * math.pi * 2,
                  blips: radar.endpoints.length,
                ),
                child: Center(
                  child: Icon(
                    Icons.wifi_tethering_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 52.sp,
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.wifi_tethering_rounded),
                label: Text(l10n.t('scan_nearby')),
                onPressed: radar.incognito
                    ? null
                    : () => radar.start(profile.endpointName),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton.filledTonal(
              icon: Icon(radar.isScanning ? Icons.stop_rounded : Icons.campaign_rounded),
              onPressed: radar.isScanning
                  ? radar.stop
                  : () => radar.advertise(profile.endpointName),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GlassPanel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.t('incognito_mode')),
                value: radar.incognito,
                onChanged: radar.setIncognito,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.t('shake_to_share')),
                value: radar.shakeEnabled,
                onChanged: (value) => radar.setShakeToShare(
                  enabled: value,
                  endpointName: profile.endpointName,
                ),
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
                l10n.t('trusted_devices'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (radar.endpoints.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(l10n.t('idle')),
                )
              else
                for (final endpoint in radar.endpoints)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.devices_rounded),
                    title: Text(endpoint.name),
                    subtitle: Text(endpoint.id),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
}
