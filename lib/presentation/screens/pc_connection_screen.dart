import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/l10n_extension.dart';
import '../controllers/file_selection_controller.dart';
import '../controllers/pc_server_controller.dart';
import '../widgets/glass_panel.dart';

class PcConnectionScreen extends StatelessWidget {
  const PcConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final files = context.watch<FileSelectionController>();
    final pc = context.watch<PcServerController>();
    final session = pc.session;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.computer_rounded, size: 42.sp),
              SizedBox(height: 12.h),
              Text(
                l10n.t('pc_title'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 8.h),
              Text(l10n.t('pc_body')),
              SizedBox(height: 18.h),
              if (session == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: pc.isStarting
                        ? SizedBox.square(
                            dimension: 18.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.t('start_pc_server')),
                    onPressed: files.selectedFiles.isEmpty || pc.isStarting
                        ? null
                        : () => pc.start(files.selectedFiles),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.t('stop_pc_server')),
                    onPressed: pc.stop,
                  ),
                ),
            ],
          ),
        ),
        if (session != null) ...[
          SizedBox(height: 16.h),
          GlassPanel(
            child: Column(
              children: [
                Text(
                  l10n.t('server_running'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: QrImageView(
                    data: session.url.toString(),
                    size: 220.w,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                SelectableText(session.url.toString()),
                SizedBox(height: 8.h),
                Text('${l10n.t('web_drop')}: ${session.uploadDirectoryPath}'),
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l10n.t('copied')),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: session.url.toString()));
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
