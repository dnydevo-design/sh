import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/utils/file_formatters.dart';
import '../controllers/cleanup_controller.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/glass_panel.dart';

class SmartCleanupScreen extends StatelessWidget {
  const SmartCleanupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cleanup = context.watch<CleanupController>();
    final transfer = context.watch<TransferController>();

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_delete_rounded, size: 42.sp),
              SizedBox(height: 12.h),
              Text(
                l10n.t('smart_cleanup'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 8.h),
              Text(l10n.t('cleanup_body')),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text(l10n.t('build_suggestions')),
                      onPressed: () {
                        cleanup.buildSuggestions(transfer.completedFiles);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filledTonal(
                    tooltip: l10n.t('delete_selected'),
                    icon: cleanup.isDeleting
                        ? SizedBox.square(
                            dimension: 18.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_rounded),
                    onPressed: cleanup.isDeleting ? null : cleanup.deleteSelected,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (cleanup.suggestions.isEmpty)
          GlassPanel(child: Text(l10n.t('idle')))
        else
          for (final suggestion in cleanup.suggestions)
            GlassPanel(
              margin: EdgeInsets.only(bottom: 10.h),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: cleanup.isSelected(suggestion.id),
                onChanged: (_) => cleanup.toggle(suggestion.id),
                title: Text(
                  suggestion.file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${formatBytes(suggestion.file.sizeBytes)} - ${suggestion.message}',
                ),
              ),
            ),
      ],
    );
  }
}
