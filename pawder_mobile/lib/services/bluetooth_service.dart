import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/dog_status_model.dart';

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

class BluetoothService extends ChangeNotifier {
  static const String _lastConnectedDeviceKey = 'last_connected_device_id';
  static const String _targetServiceUuid = '12345678-1234-1234-1234-123456789abc';
  static const String _targetCharacteristicUuid = '87654321-4321-4321-4321-cba987654321';

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  DogStatusData? _currentDogStatus;
  List<BluetoothDevice> _availableDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectionStatus;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  DogStatusData? get currentDogStatus => _currentDogStatus;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String? get connectionStatus => _connectionStatus;

  Future<void> initialize() async {
    try {
      // Bluetooth状態をチェック
      if (Platform.isAndroid) {
        await _checkAndRequestPermissions();
      }

      // 過去に接続したデバイスを自動接続
      await _connectToLastDevice();
      
      // バックグラウンドタスクをスケジュール
      _scheduleBackgroundTask();
    } catch (e) {
      print('Bluetooth initialization error: $e');
      _connectionStatus = 'Bluetooth初期化エラー: $e';
      notifyListeners();
    }
  }

  void _scheduleBackgroundTask() {
    // バックグラウンドで接続状態を維持するタスクを設定
    // 注意: 実際の実装では、プラットフォームの制限により効果が制限される場合があります
    try {
      // Workmanager().registerPeriodicTask(
      //   "bluetoothBackgroundTask",
      //   "bluetoothBackgroundTask",
      //   frequency: Duration(minutes: 15),
      // );
      print('Background task scheduling attempted');
    } catch (e) {
      print('Failed to schedule background task: $e');
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Android 12 以降の権限処理
      final bluetoothScan = await Permission.bluetoothScan.status;
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      final location = await Permission.location.status;

      List<Permission> permissionsToRequest = [];

      if (!bluetoothScan.isGranted) {
        permissionsToRequest.add(Permission.bluetoothScan);
      }
      if (!bluetoothConnect.isGranted) {
        permissionsToRequest.add(Permission.bluetoothConnect);
      }
      if (!location.isGranted) {
        permissionsToRequest.add(Permission.location);
      }

      if (permissionsToRequest.isNotEmpty) {
        await permissionsToRequest.request();
      }

      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        print('Failed to turn on Bluetooth: $e');
      }
    } else if (Platform.isIOS) {
      // iOS の場合、権限は自動的にリクエストされる
      print('iOS detected - Bluetooth permissions will be requested automatically');
    }
  }

  Future<void> startScanning() async {
    if (_isScanning) return;

    try {
      _isScanning = true;
      _availableDevices.clear();
      _connectionStatus = 'デバイスをスキャン中...';
      notifyListeners();

      // スキャンを開始
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [], // 特定のサービスがある場合は指定
      );

      // スキャン結果を監視
      FlutterBluePlus.scanResults.listen((results) {
        final newDevices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .map((r) => r.device)
            .toList();

        _availableDevices = newDevices;
        notifyListeners();
      });

      // スキャン完了を監視
      await Future.delayed(const Duration(seconds: 10));
      await FlutterBluePlus.stopScan();
      
      _isScanning = false;
      _connectionStatus = '${_availableDevices.length}個のデバイスが見つかりました';
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      _connectionStatus = 'スキャンエラー: $e';
      notifyListeners();
      print('Scan error: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;

    try {
      _isConnecting = true;
      _connectionStatus = '${device.platformName}に接続中...';
      notifyListeners();

      // 既存の接続を切断
      if (_connectedDevice != null) {
        await disconnect();
      }

      // デバイスに接続
      await device.connect();
      _connectedDevice = device;

      // 接続状態を監視
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // サービスを発見
      final services = await device.discoverServices();
      
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
              print('Using characteristic: ${characteristic.uuid}');
              break;
            }
          }
          if (_targetCharacteristic != null) break;
        }
      }

      if (_targetCharacteristic != null) {
        // 特性の通知を有効化
        if (_targetCharacteristic!.properties.notify) {
          await _targetCharacteristic!.setNotifyValue(true);
          
          // データの受信を開始
          _characteristicSubscription = _targetCharacteristic!.lastValueStream.listen(
            _handleReceivedData,
            onError: (error) {
              print('Characteristic subscription error: $error');
            },
          );
        }

        // デバイスIDを保存
        await _saveLastConnectedDevice(device.remoteId.str);
        
        _isConnecting = false;
        _connectionStatus = '${device.platformName}に接続済み';
        notifyListeners();
      } else {
        throw Exception('対応する特性が見つかりません');
      }
    } catch (e) {
      _isConnecting = false;
      _connectedDevice = null;
      _connectionStatus = '接続エラー: $e';
      notifyListeners();
      print('Connection error: $e');
    }
  }

  void _handleReceivedData(List<int> data) {
    try {
      final dataString = String.fromCharCodes(data).trim();
      print('Received data: $dataString');

      if (dataString.isNotEmpty) {
        final dogStatus = DogStatusData.fromString(dataString);
        _currentDogStatus = dogStatus;
        notifyListeners();
      }
    } catch (e) {
      print('Data parsing error: $e');
    }
  }

  void _handleDisconnection() {
    print('Device disconnected');
    _connectedDevice = null;
    _targetCharacteristic = null;
    _characteristicSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectionStatus = '接続が切断されました';
    notifyListeners();

    // 自動再接続を試行
    _attemptReconnection();
  }

  Future<void> _attemptReconnection() async {
    await Future.delayed(const Duration(seconds: 3));
    await _connectToLastDevice();
  }

  Future<void> _connectToLastDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDeviceId = prefs.getString(_lastConnectedDeviceKey);
      
      if (lastDeviceId != null) {
        _connectionStatus = '前回のデバイスに自動接続中...';
        notifyListeners();

        // 接続済みデバイスをチェック
        final connectedDevices = await FlutterBluePlus.connectedSystemDevices;
        for (final device in connectedDevices) {
          if (device.remoteId.str == lastDeviceId) {
            await connectToDevice(device);
            return;
          }
        }

        // 短時間スキャンして前回のデバイスを探す
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
        
        FlutterBluePlus.scanResults.listen((results) async {
          for (final result in results) {
            if (result.device.remoteId.str == lastDeviceId) {
              await FlutterBluePlus.stopScan();
              await connectToDevice(result.device);
              return;
            }
          }
        });

        await Future.delayed(const Duration(seconds: 5));
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      print('Auto-connect error: $e');
    }
  }

  Future<void> _saveLastConnectedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastConnectedDeviceKey, deviceId);
  }

  Future<void> disconnect() async {
    try {
      _characteristicSubscription?.cancel();
      _connectionSubscription?.cancel();
      
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      
      _connectedDevice = null;
      _targetCharacteristic = null;
      _connectionStatus = '切断されました';
      notifyListeners();
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  @override
  void dispose() {
    _characteristicSubscription?.cancel();
    _connectionSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}