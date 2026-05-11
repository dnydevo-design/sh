import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../core/l10n/fast_share_localizations.dart';
import '../core/theme/app_theme.dart';
import '../presentation/controllers/cleanup_controller.dart';
import '../presentation/controllers/file_selection_controller.dart';
import '../presentation/controllers/chat_controller.dart';
import '../presentation/controllers/profile_controller.dart';
import '../presentation/controllers/pro_tools_controller.dart';
import '../presentation/controllers/pc_server_controller.dart';
import '../presentation/controllers/permission_controller.dart';
import '../presentation/controllers/radar_controller.dart';
import '../presentation/controllers/settings_controller.dart';
import '../presentation/controllers/transfer_controller.dart';
import '../presentation/controllers/vault_controller.dart';
import '../presentation/screens/splash_gate.dart';
import 'app_dependencies.dart';

class FastShareApp extends StatelessWidget {
  const FastShareApp({
    required this.dependencies,
    super.key,
  });

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: dependencies),
        ChangeNotifierProvider(
          create: (_) => SettingsController(dependencies.preferences)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(dependencies.profileService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionController(
            dependencies.permissionService,
            dependencies.preferences,
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => FileSelectionController(
            dependencies.filePickerService,
            dependencies.smartClassifierService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransferController(
            dependencies.socketTransferService,
            dependencies.nearbyConnectivityService,
            dependencies.transferNotificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RadarController(
            dependencies.nearbyConnectivityService,
            dependencies.shakeDetectionService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PcServerController(dependencies.pcHttpServerService),
        ),
        ChangeNotifierProvider(
          create: (_) => CleanupController(dependencies.smartCleanupService),
        ),
        ChangeNotifierProvider(
          create: (_) => VaultController(dependencies.vaultService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatController(
            dependencies.offlineChatService,
            dependencies.clipboardSyncService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProToolsController(
            dependencies.compressionService,
            dependencies.scheduledTransferService,
            dependencies.remoteCameraService,
          )..load(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Fast Share',
                locale: settings.locale,
                supportedLocales: FastShareLocalizations.supportedLocales,
                localizationsDelegates: const [
                  FastShareLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: settings.themeMode,
                home: child,
              );
            },
            child: const SplashGate(),
          );
        },
      ),
    );
  }
}
