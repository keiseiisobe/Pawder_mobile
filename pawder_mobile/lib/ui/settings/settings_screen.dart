import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../../providers/bluetooth_repository_provider.dart';

class DeviceConnectionModel {
  DeviceConnectionModel({
    this.deviceId,
    this.deviceName,
    required this.isConnected,
    this.connectionStatus,
  });

  final String? deviceId;
  final String? deviceName;
  final bool isConnected;
  final String? connectionStatus;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings ViewModelから移動したデータ
  String ownerName = '山田 太郎';
  String email = 'taro.yamada@example.com';
  bool isAutoSyncEnabled = true;

  void toggleAutoSync(bool value) {
    setState(() {
      isAutoSyncEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothRepositoryProvider>();
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
                    subtitle: Text(ownerName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement edit flow
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('メールアドレス'),
                    subtitle: Text(email),
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
                    'Bluetooth デバイス',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 接続状態表示
                  _BluetoothConnectionStatus(
                    bluetoothProvider: bluetoothProvider,
                  ),
                  const Divider(),
                  // デバイススキャンボタン
                  _ScanButton(
                    isScanning: bluetoothProvider.isScanning,
                    onScan: () => bluetoothProvider.startScanning(),
                  ),
                  const SizedBox(height: 8),
                  // Bluetooth診断ボタン
                  _DiagnosticsButton(
                    onDiagnostics: () => _showDiagnostics(context, bluetoothProvider),
                  ),
                  const SizedBox(height: 8),
                  // 利用可能なデバイスリスト
                  _AvailableDevicesList(
                    devices: bluetoothProvider.availableDevices,
                    onConnect: (device) => bluetoothProvider.connectToDevice(device),
                    connectedDeviceId: bluetoothProvider.deviceId,
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
                    'アプリ設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('自動同期'),
                    subtitle: const Text('アプリ起動時にデータを自動同期します'),
                    value: isAutoSyncEnabled,
                    onChanged: toggleAutoSync,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDiagnostics(BuildContext context, BluetoothRepositoryProvider provider) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth診断'),
        content: FutureBuilder<String>(
          future: _getDiagnostics(provider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return Text('エラー: ${snapshot.error}');
            }
            
            return SingleChildScrollView(
              child: Text(
                snapshot.data ?? '診断情報を取得できませんでした',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<String> _getDiagnostics(BluetoothRepositoryProvider provider) async {
    final buffer = StringBuffer();
    
    try {
      buffer.writeln('=== Bluetooth 診断情報 ===\n');
      
      // Bluetooth状態
      final isBluetoothOn = await provider.checkBluetoothStatus();
      buffer.writeln('Bluetooth状態: ${isBluetoothOn ? "ON" : "OFF"}');
      
      // 接続状態
      buffer.writeln('接続状態: ${provider.isConnected ? "接続済み" : "未接続"}');
      
      if (provider.isConnected) {
        buffer.writeln('接続デバイス: ${provider.deviceName ?? "不明"}');
        buffer.writeln('デバイスID: ${provider.deviceId ?? "不明"}');
      }
      
      // スキャン状態
      buffer.writeln('スキャン中: ${provider.isScanning ? "はい" : "いいえ"}');
      
      // 利用可能デバイス数
      buffer.writeln('発見されたデバイス数: ${provider.availableDevices.length}');
      
      if (provider.availableDevices.isNotEmpty) {
        buffer.writeln('\n=== 発見されたデバイス ===');
        for (int i = 0; i < provider.availableDevices.length; i++) {
          final device = provider.availableDevices[i];
          buffer.writeln('${i + 1}. ${device.platformName.isNotEmpty ? device.platformName : "Unknown"}');
          buffer.writeln('   ID: ${device.remoteId.str}');
        }
      }
      
      // アダプタ状態
      try {
        final adapterState = await FlutterBluePlus.adapterState.first;
        buffer.writeln('\nアダプタ状態: $adapterState');
      } catch (e) {
        buffer.writeln('\nアダプタ状態取得エラー: $e');
      }
      
    } catch (e) {
      buffer.writeln('診断エラー: $e');
    }
    
    return buffer.toString();
  }
}

class _BluetoothConnectionStatus extends StatelessWidget {
  const _BluetoothConnectionStatus({
    required this.bluetoothProvider,
  });

  final BluetoothRepositoryProvider bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    if (bluetoothProvider.isConnected) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.bluetooth_connected,
          color: Colors.green,
        ),
        title: Text(bluetoothProvider.deviceName ?? '不明なデバイス'),
        subtitle: Text('接続済み • ${bluetoothProvider.deviceId}'),
        trailing: ElevatedButton(
          onPressed: () => bluetoothProvider.disconnect(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(60, 32),
          ),
          child: const Text(
            '切断',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.bluetooth_disabled,
          color: Colors.grey,
        ),
        title: const Text('デバイス未接続'),
        subtitle: const Text('下記のリストからデバイスを選択してください'),
      );
    }
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.isScanning,
    required this.onScan,
  });

  final bool isScanning;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isScanning ? null : onScan,
        icon: isScanning
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search),
        label: Text(isScanning ? 'スキャン中...' : 'デバイスを検索'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsButton extends StatelessWidget {
  const _DiagnosticsButton({
    required this.onDiagnostics,
  });

  final VoidCallback onDiagnostics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onDiagnostics,
        icon: const Icon(Icons.info_outline),
        label: const Text('Bluetooth診断'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _AvailableDevicesList extends StatelessWidget {
  const _AvailableDevicesList({
    required this.devices,
    required this.onConnect,
    this.connectedDeviceId,
  });

  final List<BluetoothDevice> devices;
  final Function(BluetoothDevice) onConnect;
  final String? connectedDeviceId;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'デバイスが見つかりません。\n「デバイスを検索」ボタンをタップしてスキャンしてください。',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '利用可能なデバイス',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...devices.map((device) => _DeviceListItem(
              device: device,
              onConnect: () => onConnect(device),
              isConnected: device.remoteId.str == connectedDeviceId,
            )),
      ],
    );
  }
}

class _DeviceListItem extends StatelessWidget {
  const _DeviceListItem({
    required this.device,
    required this.onConnect,
    required this.isConnected,
  });

  final BluetoothDevice device;
  final VoidCallback onConnect;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(
          device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(device.remoteId.str),
        trailing: ElevatedButton(
          onPressed: isConnected ? null : onConnect,
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.grey : Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(60, 32),
          ),
          child: Text(
            isConnected ? '接続済み' : '接続',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}