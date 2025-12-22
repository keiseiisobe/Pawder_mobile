import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../repositories/bluetooth_repository.dart';
import '../models/dog_status_model.dart';

/// Bluetooth Service - ビジネスロジック層
/// UIとRepositoryの間で動作し、複雑なBluetoothロジックを管理
class BluetoothService extends ChangeNotifier {
  final BluetoothRepository _bluetoothRepository;

  // 状態管理
  List<BluetoothDevice> _availableDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectionStatus;
  DogStatusData? _currentDogStatus;
  DeviceConnectionModel _connectionModel = DeviceConnectionModel(
    isConnected: false,
  );

  // Subscriptions
  StreamSubscription<DogStatusData>? _dogStatusSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<BluetoothDevice>>? _scanResultsSubscription;

  BluetoothService({BluetoothRepository? bluetoothRepository})
    : _bluetoothRepository = bluetoothRepository ?? BluetoothRepository() {
    _initializeSubscriptions();
  }

  // Getters
  List<BluetoothDevice> get availableDevices => _availableDevices;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String? get connectionStatus => _connectionStatus;
  DogStatusData? get currentDogStatus => _currentDogStatus;
  BluetoothDevice? get connectedDevice => _bluetoothRepository.connectedDevice;
  DeviceConnectionModel get connectionModel => _connectionModel;

  // リアルタイム更新のためのストリームへのアクセス
  Stream<DogStatusData> get dogStatusStream =>
      _bluetoothRepository.dogStatusStream;
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _bluetoothRepository.connectionStateStream;

  /// Bluetooth状態の診断
  Future<String> getDiagnostics() async {
    final buffer = StringBuffer();

    try {
      // Bluetoothサポート
      final isSupported = await FlutterBluePlus.isSupported;
      buffer.writeln('Bluetoothサポート: ${isSupported ? "対応" : "非対応"}');

      // Bluetooth状態
      final adapterState = FlutterBluePlus.adapterStateNow;
      buffer.writeln('Bluetooth状態: ${_getAdapterStateText(adapterState)}');

      // 接続状態
      buffer.writeln('接続状態: ${connectedDevice?.platformName ?? "未接続"}');
    } catch (e) {
      buffer.writeln('診断エラー: $e');
    }

    return buffer.toString();
  }

  String _getAdapterStateText(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return '不明';
      case BluetoothAdapterState.unavailable:
        return '利用不可';
      case BluetoothAdapterState.unauthorized:
        return '未許可';
      case BluetoothAdapterState.turningOn:
        return '起動中';
      case BluetoothAdapterState.on:
        return 'オン';
      case BluetoothAdapterState.turningOff:
        return '停止中';
      case BluetoothAdapterState.off:
        return 'オフ';
    }
  }

  /// 初期化
  Future<void> initialize() async {
    try {
      print('Bluetooth初期化開始');

      // Bluetoothサポートチェック
      if (await FlutterBluePlus.isSupported == false) {
        throw BluetoothServiceException('このデバイスはBluetoothをサポートしていません');
      }

      // Bluetoothアダプタ状態を確認
      print('Bluetooth状態確認中...');
      final adapterState = await FlutterBluePlus.adapterState.first;
      print('Bluetooth状態: $adapterState');

      if (adapterState != BluetoothAdapterState.on) {
        throw BluetoothServiceException(
          'Bluetoothが無効です。設定でBluetoothを有効にしてください。',
        );
      }

      // 自動再接続試行
      print('自動再接続試行');
      await _attemptAutoReconnect();

      _connectionStatus = 'Bluetooth初期化完了';
      print('Bluetooth初期化完了');
      notifyListeners();
    } catch (e) {
      print('Bluetooth初期化エラー: $e');
      _connectionStatus = 'Bluetooth初期化エラー: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// ストリームの初期化
  void _initializeSubscriptions() {
    _dogStatusSubscription = _bluetoothRepository.dogStatusStream.listen((
      dogStatus,
    ) {
      print(
        'BluetoothService: 犬のステータス更新 - ${dogStatus.behavior}, バッテリー: ${dogStatus.battery}%',
      );
      _currentDogStatus = dogStatus;
      _updateConnectionModel();
      // データ更新時の通知を強化
      print('BluetoothService: ステータス更新通知を送信中...');
      notifyListeners();
    });

    _connectionStateSubscription = _bluetoothRepository.connectionStateStream
        .listen((state) {
          print('BluetoothService: 接続状態変更 - $state');
          _updateConnectionStatus(state);
          _updateConnectionModel();
          // 接続状態変更時の通知を強化
          print('BluetoothService: 接続状態変更通知を送信中...');
          notifyListeners();
        });

    _scanResultsSubscription = _bluetoothRepository.scanResultsStream.listen((
      devices,
    ) {
      _availableDevices = devices;
      notifyListeners();
    });
  }

  /// デバイススキャンを開始
  Future<void> startScanning() async {
    if (_isScanning) return;

    try {
      print('スキャン開始');

      // Bluetoothアダプタ状態を確認
      final adapterState = FlutterBluePlus.adapterStateNow;
      print('Bluetooth状態: $adapterState');

      if (adapterState != BluetoothAdapterState.on) {
        throw BluetoothServiceException(
          'Bluetoothが無効です。設定でBluetoothを有効にしてください。',
        );
      }

      _isScanning = true;
      _availableDevices.clear();
      _connectionStatus = 'デバイスをスキャン中...';
      notifyListeners();

      print('スキャン実行開始');
      await _bluetoothRepository.startScan();
      print('スキャン完了');
    } catch (e) {
      print('スキャンエラー: $e');
      _isScanning = false;
      _connectionStatus = 'スキャンエラー: $e';
      notifyListeners();
      throw BluetoothServiceException('デバイススキャンに失敗しました: $e');
    } finally {
      _isScanning = false;
      _connectionStatus = '${_availableDevices.length}個のデバイスが見つかりました';
      notifyListeners();
    }
  }

  /// デバイスに接続
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;

    try {
      _isConnecting = true;
      _connectionStatus = '${device.platformName}に接続中...';
      notifyListeners();

      await _bluetoothRepository.connectToDevice(device);

      _connectionStatus = '${device.platformName}に接続済み';
      _updateConnectionModel();

      // 接続完了時の通知を強化（HomeScreenのリビルドを確実にトリガー）
      print('BluetoothService: デバイス接続完了 - ${device.platformName}');
      print('BluetoothService: 接続完了通知を送信中...');
      notifyListeners();

      // 接続後、データストリームの開始を確認
      Future.delayed(const Duration(milliseconds: 500), () {
        print('BluetoothService: 接続後の状態確認...');
        _updateConnectionModel();
        notifyListeners();
      });
    } catch (e) {
      _connectionStatus = '接続エラー: $e';
      _updateConnectionModel();
      notifyListeners();
      throw BluetoothServiceException('デバイス接続に失敗しました: $e');
    } finally {
      _isConnecting = false;
    }
  }

  /// デバイスから切断
  Future<void> disconnect() async {
    try {
      await _bluetoothRepository.disconnect();
      _connectionStatus = '切断されました';
      _currentDogStatus = null;
      _updateConnectionModel();
      notifyListeners();
    } catch (e) {
      throw BluetoothServiceException('切断に失敗しました: $e');
    }
  }

  /// 自動再接続を試行
  Future<void> _attemptAutoReconnect() async {
    try {
      final lastDeviceId = await _bluetoothRepository
          .getLastConnectedDeviceId();
      if (lastDeviceId == null) return;

      _connectionStatus = '前回のデバイスに自動接続中...';
      notifyListeners();

      // システム接続デバイスをチェック
      final connectedDevices = await _bluetoothRepository
          .getConnectedSystemDevices();
      for (final device in connectedDevices) {
        if (device.remoteId.str == lastDeviceId) {
          await connectToDevice(device);
          return;
        }
      }

      // 短時間スキャンして探す
      await startScanning();
      await Future.delayed(const Duration(seconds: 5));

      final foundDevice = _availableDevices
          .where((device) => device.remoteId.str == lastDeviceId)
          .firstOrNull;

      if (foundDevice != null) {
        await connectToDevice(foundDevice);
      }
    } catch (e) {
      print('Auto-reconnect failed: $e');
      _connectionStatus = '自動接続に失敗しました';
      notifyListeners();
    }
  }

  /// 接続状態を更新
  void _updateConnectionStatus(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        _connectionStatus = '接続済み';
        break;
      case BluetoothConnectionState.disconnected:
        _connectionStatus = '切断されました';
        _currentDogStatus = null;
        // 自動再接続を試行
        Future.delayed(const Duration(seconds: 3), _attemptAutoReconnect);
        break;
      case BluetoothConnectionState.connecting:
        _connectionStatus = '接続中...';
        break;
      case BluetoothConnectionState.disconnecting:
        _connectionStatus = '切断中...';
        break;
    }
  }

  /// 接続モデルを更新
  void _updateConnectionModel() {
    final device = _bluetoothRepository.connectedDevice;
    _connectionModel = DeviceConnectionModel(
      deviceId: device?.remoteId.str,
      deviceName: device?.platformName,
      isConnected: device != null,
      connectionStatus: _connectionStatus,
    );
  }

  @override
  void dispose() {
    _dogStatusSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _bluetoothRepository.dispose();
    super.dispose();
  }
}

/// Bluetooth Service例外クラス
class BluetoothServiceException implements Exception {
  final String message;

  BluetoothServiceException(this.message);

  @override
  String toString() => 'BluetoothServiceException: $message';
}
