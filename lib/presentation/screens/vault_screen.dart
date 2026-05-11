import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/utils/file_formatters.dart';
import '../controllers/file_selection_controller.dart';
import '../controllers/vault_controller.dart';
import '../widgets/glass_panel.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultController>();
    final files = context.watch<FileSelectionController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('vault'))),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          GlassPanel(
            child: Column(
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.t('password')),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: vault.isBusy
                        ? SizedBox.square(
                            dimension: 18.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_rounded),
                    label: Text(l10n.t('encrypt_selected')),
                    onPressed: vault.isBusy
                        ? null
                        : () => vault.encryptSelected(
                              files: files.selectedFiles,
                              password: _passwordController.text,
                            ),
                  ),
                ),
                if (vault.error != null) ...[
                  SizedBox(height: 8.h),
                  Text(vault.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          for (final record in vault.records)
            GlassPanel(
              margin: EdgeInsets.only(bottom: 10.h),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.enhanced_encryption_rounded),
                title: Text(record.name),
                subtitle: Text(formatBytes(record.encryptedSizeBytes)),
                trailing: TextButton(
                  onPressed: () => vault.decrypt(
                    record: record,
                    password: _passwordController.text,
                  ),
                  child: Text(l10n.t('decrypt')),
                ),
              ),
            ),
          if (vault.lastOutputPath != null)
            SelectableText(vault.lastOutputPath!),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

