import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/utils/file_formatters.dart';
import '../../domain/entities/transfer_progress.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/glass_panel.dart';
import '../widgets/metric_chip.dart';

class TransferDashboardScreen extends StatelessWidget {
  const TransferDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransferController>();
    final progress = controller.progress;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('dashboard'))),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _phaseLabel(context, progress.phase),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(progress.currentFileName ?? l10n.t('app_name')),
                SizedBox(height: 20.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.phase == TransferPhase.completed
                        ? 1
                        : progress.fraction,
                    minHeight: 12.h,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '${formatBytes(progress.bytesTransferred)} / ${formatBytes(progress.totalBytes)}',
                ),
                if (progress.errorMessage != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    progress.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              MetricChip(
                icon: Icons.speed_rounded,
                label: l10n.t('speed'),
                value: formatSpeed(progress.bytesPerSecond),
              ),
              SizedBox(width: 10.w),
              MetricChip(
                icon: Icons.timer_rounded,
                label: l10n.t('eta'),
                value: formatDuration(progress.eta),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('completed'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 8.h),
                if (controller.completedFiles.isEmpty)
                  Text(l10n.t('idle'))
                else
                  for (final file in controller.completedFiles)
                    Text('- ${file.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(BuildContext context, TransferPhase phase) {
    final l10n = context.l10n;
    return switch (phase) {
      TransferPhase.idle => l10n.t('idle'),
      TransferPhase.preparing => l10n.t('preparing'),
      TransferPhase.waitingForPeer => l10n.t('waiting_peer'),
      TransferPhase.transferring => l10n.t('transferring'),
      TransferPhase.completed => l10n.t('completed'),
      TransferPhase.failed => l10n.t('failed'),
    };
  }
}
