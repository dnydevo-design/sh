import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_formatters.dart';
import '../../domain/entities/peer_invite.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/enums/file_category.dart';
import '../controllers/file_selection_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/pro_tools_controller.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/file_tile.dart';
import '../widgets/glass_panel.dart';
import 'transfer_dashboard_screen.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final files = context.watch<FileSelectionController>();
    final profile = context.watch<ProfileController>();
    final transfer = context.watch<TransferController>();
    final tools = context.watch<ProToolsController>();
    final l10n = context.l10n;
    final invite = transfer.invite;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -700 &&
            files.selectedFiles.isNotEmpty) {
          context.read<TransferController>().prepareSend(
                files.selectedFiles,
                endpointName: profile.endpointName,
              );
        }
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
        _HeroPanel(
          title: l10n.t('send'),
          subtitle:
              '${files.selectedFiles.length} - ${formatBytes(files.totalBytes)}',
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final category in FileCategory.values)
              ChoiceChip(
                label: Text(l10n.t(category.labelKey)),
                selected: files.category == category,
                onSelected: (_) => files.setCategory(category),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: files.isPicking
                    ? SizedBox.square(
                        dimension: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file_rounded),
                label: Text(l10n.t('pick_files')),
                onPressed: files.isPicking ? null : files.pickCurrentCategory,
              ),
            ),
            SizedBox(width: 10.w),
            IconButton.filledTonal(
              tooltip: l10n.t('remove'),
              onPressed: files.selectedFiles.isEmpty ? null : files.clear,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('selected_files'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 8.h),
              if (files.selectedFiles.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(child: Text(l10n.t('no_files'))),
                )
              else
                for (final file in files.selectedFiles)
                  FileTile(
                    file: file,
                    onRemove: () => files.remove(file.id),
                  ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Fast Zip & Send button — compresses first, then starts session
        if (files.selectedFiles.length > 1) ...[
          _FastZipSendButton(
            files: files.selectedFiles,
            tools: tools,
            transfer: transfer,
            profile: profile,
            l10n: l10n,
          ),
          SizedBox(height: 10.h),
        ],

        FilledButton.icon(
          icon: const Icon(Icons.bolt_rounded),
          label: Text(l10n.t('start_session')),
          onPressed: files.selectedFiles.isEmpty
              ? null
              : () async {
                  await context
                      .read<TransferController>()
                      .prepareSend(
                        files.selectedFiles,
                        endpointName: profile.endpointName,
                      );
                },
        ),
        if (invite != null) ...[
          SizedBox(height: 16.h),
          GlassPanel(
            child: Column(
              children: [
                Text(
                  l10n.t('waiting_peer'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: 6.h),
                Text(l10n.t('show_qr'), textAlign: TextAlign.center),
                SizedBox(height: 6.h),
                Text(
                  l10n.t(
                    invite.transport == PeerTransport.hotspot
                        ? 'transport_hotspot'
                        : 'transport_socket',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: QrImageView(
                    data: invite.toQrPayload(),
                    size: 220.w,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                SelectableText('${invite.host}:${invite.port}'),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(l10n.t('copied')),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: invite.toQrPayload()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.speed_rounded),
                        label: Text(l10n.t('dashboard')),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TransferDashboardScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ],
      ),
    );
  }
}

/// A button that compresses selected files into a .zip, then starts the transfer.
class _FastZipSendButton extends StatefulWidget {
  const _FastZipSendButton({
    required this.files,
    required this.tools,
    required this.transfer,
    required this.profile,
    required this.l10n,
  });

  final List<TransferFile> files;
  final ProToolsController tools;
  final TransferController transfer;
  final ProfileController profile;
  final dynamic l10n;

  @override
  State<_FastZipSendButton> createState() => _FastZipSendButtonState();
}

class _FastZipSendButtonState extends State<_FastZipSendButton> {
  bool _isZipping = false;

  @override
  Widget build(BuildContext context) {
    final tools = widget.tools;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          icon: _isZipping
              ? SizedBox.square(
                  dimension: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Icon(Icons.archive_rounded),
          label: Text(widget.l10n.t('fast_zip_send')),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.magenta,
            foregroundColor: Colors.white,
          ),
          onPressed: _isZipping
              ? null
              : () async {
                  setState(() => _isZipping = true);
                  await tools.compress(widget.files);
                  if (tools.zipPath != null && mounted) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(widget.l10n.t('compression_success')),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.successGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Create a TransferFile for the zip and start session
                    final zipFile = TransferFile(
                      id: 'zip-${DateTime.now().millisecondsSinceEpoch}',
                      path: tools.zipPath!,
                      name: tools.zipPath!.split('/').last,
                      sizeBytes: await _getFileSize(tools.zipPath!),
                      category: FileCategory.archives,
                    );
                    await widget.transfer.prepareSend(
                      [zipFile],
                      endpointName: widget.profile.endpointName,
                    );
                  }
                  if (mounted) setState(() => _isZipping = false);
                },
        ),
        if (_isZipping) ...[
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: tools.compressionProgress,
              minHeight: 6.h,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.magenta),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${widget.l10n.t("compressing")} ${(tools.compressionProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: AppTheme.magenta,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Future<int> _getFileSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (_) {
      return 0;
    }
  }
}
