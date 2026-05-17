import 'package:flutter/material.dart';
import '../../core/l10n/l10n_extension.dart';
import 'pc_connection_screen.dart';
import 'profile_screen.dart';
import 'pro_tools_screen.dart';
import 'receive_screen.dart';
import 'radar_screen.dart';
import 'send_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'transfer_dashboard_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      const SendScreen(),
      const RadarScreen(),
      const ReceiveScreen(),
      const PcConnectionScreen(),
      const ProToolsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('app_name')),
        actions: [
          IconButton(
            tooltip: l10n.t('support'),
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.t('dashboard'),
            icon: const Icon(Icons.speed_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransferDashboardScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.t('profile'),
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.t('settings'),
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.upload_rounded),
            label: l10n.t('send'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.wifi_tethering_rounded),
            label: l10n.t('radar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.download_rounded),
            label: l10n.t('receive'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.computer_rounded),
            label: l10n.t('pc'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.construction_rounded),
            label: l10n.t('tools'),
          ),
        ],
      ),
    );
  }
}
