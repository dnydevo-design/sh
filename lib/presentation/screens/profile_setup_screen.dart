import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_extension.dart';
import '../controllers/profile_controller.dart';
import '../widgets/glass_panel.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  var _avatarSeed = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/icon/fast_share_icon.svg',
                width: 128.w,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.t('profile'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(l10n.t('permissions_subtitle')),
            SizedBox(height: 20.h),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: l10n.t('username')),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    l10n.t('avatar'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    children: [
                      for (var i = 0; i < 6; i++)
                        ChoiceChip(
                          label: CircleAvatar(
                            backgroundColor: _avatarColor(i),
                            child: Text('${i + 1}'),
                          ),
                          selected: _avatarSeed == i,
                          onSelected: (_) => setState(() => _avatarSeed = i),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            FilledButton.icon(
              icon: const Icon(Icons.person_add_rounded),
              label: Text(l10n.t('create_profile')),
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.length < 2) {
                  return;
                }
                context.read<ProfileController>().save(
                      username: name,
                      avatarSeed: _avatarSeed,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(int seed) {
    const colors = [
      Color(0xFF00E5FF),
      Color(0xFFFF2BD6),
      Color(0xFF8B5CF6),
      Color(0xFF22C55E),
      Color(0xFFF97316),
      Color(0xFFEAB308),
    ];
    return colors[seed % colors.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

