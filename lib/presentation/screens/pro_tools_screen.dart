import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/utils/file_formatters.dart';
import '../controllers/file_selection_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/pro_tools_controller.dart';
import '../widgets/glass_panel.dart';
import 'chat_screen.dart';
import 'smart_cleanup_screen.dart';
import 'vault_screen.dart';

class ProToolsScreen extends StatelessWidget {
  const ProToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = context.watch<ProToolsController>();
    final files = context.watch<FileSelectionController>();
    final profile = context.watch<ProfileController>();
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _ToolAction(
          icon: Icons.lock_rounded,
          title: l10n.t('vault'),
          subtitle: l10n.t('encrypt_selected'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VaultScreen()),
          ),
        ),
        _ToolAction(
          icon: Icons.chat_rounded,
          title: l10n.t('chat'),
          subtitle: l10n.t('clipboard_sync'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          ),
        ),
        _ToolAction(
          icon: Icons.auto_delete_rounded,
          title: l10n.t('smart_cleanup'),
          subtitle: l10n.t('cleanup_body'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SmartCleanupScreen()),
          ),
        ),
        GlassPanel(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(icon: Icons.archive_rounded, title: l10n.t('compress')),
              SizedBox(height: 8.h),
              Text('${files.selectedFiles.length} - ${formatBytes(files.totalBytes)}'),
              SizedBox(height: 10.h),
              FilledButton.icon(
                icon: tools.isCompressing
                    ? SizedBox.square(
                        dimension: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.archive_rounded),
                label: Text(l10n.t('compress')),
                onPressed: tools.isCompressing
                    ? null
                    : () => tools.compress(files.selectedFiles),
              ),
              if (tools.zipPath != null) ...[
                SizedBox(height: 8.h),
                SelectableText(tools.zipPath!),
              ],
            ],
          ),
        ),
        GlassPanel(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(icon: Icons.camera_alt_rounded, title: l10n.t('remote_camera')),
              SizedBox(height: 8.h),
              Text(l10n.t('live_preview')),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.t('remote_camera')),
                      onPressed: tools.startRemoteCamera,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.stop_rounded),
                    onPressed: tools.stopRemoteCamera,
                  ),
                ],
              ),
              if (tools.cameraState != null) ...[
                SizedBox(height: 8.h),
                Text(tools.cameraState!),
              ],
            ],
          ),
        ),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                icon: Icons.schedule_send_rounded,
                title: l10n.t('scheduled_transfer'),
              ),
              SizedBox(height: 8.h),
              if (profile.trustedDevices.isEmpty)
                Text(l10n.t('trusted_devices'))
              else
                for (final device in profile.trustedDevices)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.devices_rounded),
                    title: Text(device.username),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_task_rounded),
                      onPressed: files.selectedFiles.isEmpty
                          ? null
                          : () => tools.queueForDevice(
                                device: device,
                                files: files.selectedFiles,
                              ),
                    ),
                  ),
              if (tools.scheduledTransfers.isNotEmpty) ...[
                const Divider(),
                for (final transfer in tools.scheduledTransfers)
                  Text('${transfer.deviceName} - ${transfer.fileIds.length}'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolAction extends StatelessWidget {
  const _ToolAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 8.w),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
