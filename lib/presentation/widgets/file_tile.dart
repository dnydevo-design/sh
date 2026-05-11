import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/utils/file_formatters.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/enums/file_category.dart';

class FileTile extends StatelessWidget {
  const FileTile({
    required this.file,
    this.onRemove,
    this.trailing,
    super.key,
  });

  final TransferFile file;
  final VoidCallback? onRemove;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(_iconFor(file.category), color: colors.primary),
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
      ),
      subtitle: Text(
        '${formatBytes(file.sizeBytes)} - ${file.classification.label}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          Wrap(
            spacing: 4.w,
            children: [
              IconButton(
                tooltip: context.l10n.t('open'),
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () => OpenFilex.open(file.path),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: context.l10n.t('remove'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onRemove,
                ),
            ],
          ),
    );
  }

  IconData _iconFor(FileCategory category) {
    return switch (category) {
      FileCategory.apps => Icons.apps_rounded,
      FileCategory.videos => Icons.movie_rounded,
      FileCategory.photos => Icons.photo_rounded,
      FileCategory.docs => Icons.description_rounded,
      FileCategory.archives => Icons.inventory_2_rounded,
      FileCategory.other => Icons.insert_drive_file_rounded,
    };
  }
}
