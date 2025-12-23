import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../repositories/bluetooth_repository.dart';
import '../services/data_service.dart';

/// BluetoothRepositoryの状態を管理するProvider
class BluetoothRepositoryProvider extends ChangeNotifier {
  BluetoothRepositoryProvider() {
    _repository = BluetoothRepository();
    _initialize();
  }

  late BluetoothRepository _repository;
  final DataService _dataService = DataService();
  StreamSubscription<DogStatusData>? _dogStatusSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<BluetoothDevice>>? _scanResultsSubscription;

  // State variables
  DogStatusData? _currentDogStatus;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothDevice> _availableDevices = [];
  bool _isScanning = false;
  String? _connectionStatus;
  BluetoothDevice? _connectedDevice;

  // Public getters
  BluetoothRepository get repository => _repository;
  DogStatusData? get currentDogStatus => _currentDogStatus;
  BluetoothConnectionState get connectionState => _connectionState;
  List<BluetoothDevice> get availableDevices => _availableDevices;
  bool get isScanning => _isScanning;
  String? get connectionStatus => _connectionStatus;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _repository.isConnected;

  // Device info properties
  String? get deviceName => _connectedDevice?.platformName;
  String? get deviceId => _connectedDevice?.remoteId.str;

  void _initialize() {
    // Streamの購読開始
    _dogStatusSubscription = _repository.dogStatusStream.listen(
      (dogStatus) {
        _currentDogStatus = dogStatus;
        
        // データサービスに新しいデータが来たことを通知
        _dataService.notifyDataChanged();
        
        notifyListeners();
      },
    );

    _connectionStateSubscription = _repository.connectionStateStream.listen(
      (state) {
        _connectionState = state;
        _connectedDevice = _repository.connectedDevice;
        _updateConnectionStatus();
        notifyListeners();
      },
    );

    _scanResultsSubscription = _repository.scanResultsStream.listen(
      (devices) {
        _availableDevices = devices;
        notifyListeners();
      },
    );
  }

  void _updateConnectionStatus() {
    switch (_connectionState) {
      case BluetoothConnectionState.connected:
        _connectionStatus = '接続済み';
        break;
      case BluetoothConnectionState.disconnected:
        _connectionStatus = '未接続';
        break;
      case BluetoothConnectionState.connecting:
        _connectionStatus = '接続中...';
        break;
      case BluetoothConnectionState.disconnecting:
        _connectionStatus = '切断中...';
        break;
    }
  }

  /// Bluetoothの初期化
  Future<void> initializeBluetooth() async {
    try {
      await _repository.initialize();
    } catch (e) {
      print('Bluetooth initialization error: $e');
      _connectionStatus = 'Bluetooth初期化エラー: $e';
      notifyListeners();
    }
  }

  /// デバイススキャンの開始
  Future<void> startScanning() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _connectionStatus = 'デバイスをスキャン中...';
    notifyListeners();

    try {
      await _repository.startScanning();
    } catch (e) {
      print('Scanning error: $e');
      _connectionStatus = 'スキャンエラー: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// デバイススキャンの停止
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    
    try {
      await _repository.stopScanning();
    } catch (e) {
      print('Stop scanning error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// デバイスに接続
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connectionStatus = '接続中...';
      notifyListeners();
      
      await _repository.connectToDevice(device);
    } catch (e) {
      print('Connection error: $e');
      _connectionStatus = '接続エラー: $e';
      notifyListeners();
    }
  }

  /// デバイスから切断
  Future<void> disconnect() async {
    try {
      await _repository.disconnect();
    } catch (e) {
      print('Disconnect error: $e');
      _connectionStatus = '切断エラー: $e';
      notifyListeners();
    }
  }

  /// 最後に接続したデバイスに自動接続を試行
  Future<void> attemptAutoConnect() async {
    try {
      await _repository.attemptAutoConnect();
    } catch (e) {
      print('Auto-connect error: $e');
    }
  }

  /// Bluetooth状態のチェック
  Future<bool> checkBluetoothStatus() async {
    return await _repository.isBluetoothOn();
  }

  @override
  void dispose() {
    _dogStatusSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}