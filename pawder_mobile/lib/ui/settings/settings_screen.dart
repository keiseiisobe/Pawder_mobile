import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('設定', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アカウント',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('名前'),
                    subtitle: Text(vm.ownerName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement edit flow
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('メールアドレス'),
                    subtitle: Text(vm.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement edit flow
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'デバイス & Bluetooth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bluetooth を有効にする'),
                    subtitle: const Text('首輪デバイスと接続します'),
                    value: vm.isBluetoothEnabled,
                    onChanged: vm.toggleBluetooth,
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('自動同期'),
                    subtitle: const Text('アプリ起動時にデータを自動同期します'),
                    value: vm.isAutoSyncEnabled,
                    onChanged: vm.toggleAutoSync,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


