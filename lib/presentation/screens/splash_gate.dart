import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/permission_controller.dart';
import '../controllers/profile_controller.dart';
import 'permission_guard_screen.dart';
import 'profile_setup_screen.dart';
import 'shell_screen.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    final permissions = context.watch<PermissionController>();
    if (!profile.isLoaded || !permissions.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!profile.hasProfile) {
      return const ProfileSetupScreen();
    }
    if (!permissions.isComplete) {
      return const PermissionGuardScreen();
    }
    return const ShellScreen();
  }
}
