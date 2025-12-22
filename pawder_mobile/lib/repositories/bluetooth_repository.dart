import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dog_status_model.dart';

/// Bluetooth Repository - データアクセス層
/// FlutterBlue Plusライブラリとの直接的なやり取りを担当
class BluetoothRepository {
  static const String _lastConnectedDeviceKey = 'last_connected_device_id';
  static const String _targetServiceUuid = '12345678-1234-1234-1234-123456789abc';
  static const String _targetCharacteristicUuid = '87654321-4321-4321-4321-cba987654321';

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // データストリーム
  final StreamController<DogStatusData> _dogStatusController = 
      StreamController<DogStatusData>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  final StreamController<List<BluetoothDevice>> _scanResultsController =
      StreamController<List<BluetoothDevice>>.broadcast();

  // Public streams
  Stream<DogStatusData> get dogStatusStream => _dogStatusController.stream;
  Stream<BluetoothConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<List<BluetoothDevice>> get scanResultsStream => _scanResultsController.stream;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  /// Bluetoothの状態をチェック
  Future<bool> isBluetoothOn() async {
    try {
      // iOS用：アダプタ状態を取得
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      print('Bluetooth状態チェックエラー: $e');
      return false;
    }
  }

  /// Bluetoothアダプタの状態を取得
  Future<BluetoothAdapterState> getAdapterState() async {
    try {
      return await FlutterBluePlus.adapterState.first;
    } catch (e) {
      print('アダプタ状態取得エラー: $e');
      return BluetoothAdapterState.unknown;
    }
  }

  /// Bluetoothを有効にする
  Future<void> turnOnBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      throw BluetoothRepositoryException('Bluetoothを有効にできませんでした: $e');
    }
  }

  /// Bluetoothスキャンを開始
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // Bluetooth状態をチェック
      final isOn = await isBluetoothOn();
      if (!isOn) {
        throw BluetoothRepositoryException('Bluetoothがオフです。設定でBluetoothを有効にしてください。');
      }

      // flutter_blue_plus固有の状態チェック
      if (await FlutterBluePlus.isSupported == false) {
        throw BluetoothRepositoryException('このデバイスはBluetoothをサポートしていません。');
      }

      await FlutterBluePlus.stopScan(); // 既存のスキャンを停止
      
      // スキャン開始前にわずかに待機
      await Future.delayed(const Duration(milliseconds: 100));
      
      await FlutterBluePlus.startScan(timeout: timeout);
      
      // スキャン結果をリスン
      final scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        final filteredDevices = <BluetoothDevice>[];
        final deviceIds = <String>{};
        
        for (final result in results) {
          final device = result.device;
          
          // 重複チェック
          if (deviceIds.contains(device.remoteId.str)) {
            continue;
          }
          
          // サービスUUIDが"44b"から始まるもののみをフィルタ
          bool hasTargetService = false;
          final advertisementData = result.advertisementData;
          
          for (final serviceUuid in advertisementData.serviceUuids) {
            if (serviceUuid.str.toLowerCase().startsWith('44b')) {
              hasTargetService = true;
              break;
            }
          }
          
          if (hasTargetService) {
            deviceIds.add(device.remoteId.str);
            filteredDevices.add(device);
            print('Found device with 44b service: ${device.platformName} (${device.remoteId.str})');
          }
        }
        
        _scanResultsController.add(filteredDevices);
      });

      // スキャン完了後にサブスクリプションをキャンセル
      await Future.delayed(timeout);
      await scanSubscription.cancel();
      await FlutterBluePlus.stopScan();
    } catch (e) {
      throw BluetoothRepositoryException('スキャンに失敗しました: $e');
    }
  }

  /// デバイスに接続
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // 既存の接続を切断
      await disconnect();

      // デバイスに接続
      await device.connect(autoConnect: false);
      _connectedDevice = device;

      // 接続状態を監視
      _connectionSubscription = device.connectionState.listen((state) {
        _connectionStateController.add(state);
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // サービスを発見
      await _discoverServices();

      // デバイスIDを保存
      await _saveLastConnectedDevice(device.remoteId.str);

      _connectionStateController.add(BluetoothConnectionState.connected);
    } catch (e) {
      _connectedDevice = null;
      throw BluetoothRepositoryException('接続に失敗しました: $e');
    }
  }

  /// サービスと特性を発見
  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    final services = await _connectedDevice!.discoverServices();
    
    // 目的のサービスと特性を見つける
    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == _targetServiceUuid.toLowerCase()) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == _targetCharacteristicUuid.toLowerCase()) {
            _targetCharacteristic = characteristic;
            break;
          }
        }
        break;
      }
    }

    if (_targetCharacteristic == null) {
      // 特定の特性が見つからない場合、最初の読み取り可能な特性を使用
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.notify || characteristic.properties.read) {
            _targetCharacteristic = characteristic;
            break;
          }
        }
        if (_targetCharacteristic != null) break;
      }
    }

    if (_targetCharacteristic != null && _targetCharacteristic!.properties.notify) {
      // 特性の通知を有効化
      await _targetCharacteristic!.setNotifyValue(true);
      
      // データの受信を開始
      _characteristicSubscription = _targetCharacteristic!.lastValueStream.listen(
        _handleReceivedData,
        onError: (error) {
          print('Characteristic subscription error: $error');
        },
      );
    }
  }

  /// 受信データを処理
  void _handleReceivedData(List<int> data) {
    try {
      final dataString = String.fromCharCodes(data).trim();
      
      if (dataString.isNotEmpty) {
        final dogStatus = DogStatusData.fromString(dataString);
        _dogStatusController.add(dogStatus);
      }
    } catch (e) {
      print('Data parsing error: $e');
    }
  }

  /// 切断処理
  Future<void> disconnect() async {
    try {
      _characteristicSubscription?.cancel();
      _connectionSubscription?.cancel();
      
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      
      _connectedDevice = null;
      _targetCharacteristic = null;
      
      _connectionStateController.add(BluetoothConnectionState.disconnected);
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  /// 切断時の処理
  void _handleDisconnection() {
    _connectedDevice = null;
    _targetCharacteristic = null;
    _characteristicSubscription?.cancel();
    _connectionSubscription?.cancel();
  }

  /// 最後に接続したデバイスを保存
  Future<void> _saveLastConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastConnectedDeviceKey, deviceId);
  }

  /// 最後に接続したデバイスIDを取得
  Future<String?> getLastConnectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastConnectedDeviceKey);
  }

  /// 接続済みシステムデバイスを取得
  Future<List<BluetoothDevice>> getConnectedSystemDevices() async {
    return await FlutterBluePlus.connectedSystemDevices;
  }

  /// 初期化処理
  Future<void> initialize() async {
    try {
      // Bluetooth状態をチェック
      final isOn = await isBluetoothOn();
      if (!isOn) {
        print('Bluetooth is off');
        return;
      }
      
      print('Bluetooth repository initialized');
    } catch (e) {
      print('Bluetooth initialization error: $e');
    }
  }

  /// スキャン開始のラッパーメソッド
  Future<void> startScanning({Duration timeout = const Duration(seconds: 10)}) async {
    await startScan(timeout: timeout);
  }

  /// スキャン停止
  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }

  /// 前回接続したデバイスへの自動接続を試行
  Future<void> attemptAutoConnect() async {
    try {
      final lastDeviceId = await getLastConnectedDeviceId();
      if (lastDeviceId == null) return;
      
      // システム接続済みデバイスから探す
      final connectedDevices = await getConnectedSystemDevices();
      for (final device in connectedDevices) {
        if (device.remoteId.str == lastDeviceId) {
          await connectToDevice(device);
          return;
        }
      }
      
      // 短時間スキャンして前回のデバイスを探す
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      
      final scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (final result in results) {
          if (result.device.remoteId.str == lastDeviceId) {
            await FlutterBluePlus.stopScan();
            await connectToDevice(result.device);
            return;
          }
        }
      });

      await Future.delayed(const Duration(seconds: 5));
      await scanSubscription.cancel();
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Auto-connect error: $e');
    }
  }

  /// リソースの解放
  void dispose() {
    _characteristicSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dogStatusController.close();
    _connectionStateController.close();
    _scanResultsController.close();
    FlutterBluePlus.stopScan();
  }
}

/// DogStatusDataクラス - データ変換を担当
class DogStatusData {
  final DogBehavior behavior;
  final int? battery;

  DogStatusData({required this.behavior, this.battery});

  factory DogStatusData.fromString(String data) {
    // JSON形式かどうかをチェック
    if (data.startsWith('{') && data.contains('behavior')) {
      try {
        final json = jsonDecode(data);
        final behaviorStr = json['behavior'] as String;
        final battery = json['battery'] as int?;
        
        return DogStatusData(
          behavior: _behaviorFromString(behaviorStr),
          battery: battery,
        );
      } catch (e) {
        print('JSON parsing error: $e');
        return DogStatusData(
          behavior: _behaviorFromString(data),
        );
      }
    } else {
      // 単純な文字列として処理
      return DogStatusData(
        behavior: _behaviorFromString(data),
      );
    }
  }

  static DogBehavior _behaviorFromString(String str) {
    switch (str.toLowerCase()) {
      case 'drinking':
        return DogBehavior.drinking;
      case 'playing':
        return DogBehavior.playing;
      case 'resting':
        return DogBehavior.resting;
      case 'shaking':
        return DogBehavior.shaking;
      case 'sniffing':
        return DogBehavior.sniffing;
      case 'trotting':
        return DogBehavior.trotting;
      case 'walking':
        return DogBehavior.walking;
      default:
        print('Unknown behavior: $str, defaulting to resting');
        return DogBehavior.resting;
    }
  }

  @override
  String toString() {
    return 'DogStatusData{behavior: $behavior, battery: $battery}';
  }
}

/// Bluetoothリポジトリの例外クラス
class BluetoothRepositoryException implements Exception {
  final String message;
  
  BluetoothRepositoryException(this.message);
  
  @override
  String toString() => 'BluetoothRepositoryException: $message';
}