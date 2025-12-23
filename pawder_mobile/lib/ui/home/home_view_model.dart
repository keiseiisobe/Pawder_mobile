import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/data_service.dart';
import '../../models/stored_data_models.dart';
import '../../providers/bluetooth_repository_provider.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final DataService _dataService = DataService();
  StreamSubscription<HomeScreenStats>? _homeStatsSubscription;
  
  HomeScreenStats _homeStats = HomeScreenStats.empty();
  bool _isLoading = true;

  HomeScreenStats get homeStats => _homeStats;
  bool get isLoading => _isLoading;

  HomeScreenViewModel() {
    _initialize();
  }

  void _initialize() async {
    // データサービスを初期化
    await _dataService.initialize();
    
    // キャッシュされたデータがあれば即座に表示
    if (_dataService.homeStats != null) {
      _homeStats = _dataService.homeStats!;
      _isLoading = false;
      notifyListeners();
    }

    // ストリームからの更新を監視
    _homeStatsSubscription = _dataService.homeStatsStream.listen((stats) {
      _homeStats = stats;
      _isLoading = false;
      notifyListeners();
    });

    // 初回データロード
    _dataService.refreshAllData();
  }

  /// 手動でデータを更新
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await _dataService.forceRefresh();
    
    _isLoading = false;
    notifyListeners();
  }

  /// デバイススキャンを開始
  Future<void> startDeviceScan(BuildContext context) async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    await bluetoothProvider.startScanning();
  }

  /// デバイスに接続
  Future<void> connectToDevice(BuildContext context, String deviceId) async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    final devices = bluetoothProvider.availableDevices;
    
    final device = devices.firstWhere(
      (d) => d.remoteId.str == deviceId,
      orElse: () => throw Exception('デバイスが見つかりません'),
    );
    
    await bluetoothProvider.connectToDevice(device);
  }

  /// デバイスから切断
  Future<void> disconnectDevice(BuildContext context) async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    await bluetoothProvider.disconnect();
  }

  /// 現在の行動表示テキスト
  String get currentBehaviorText {
    switch (_homeStats.currentBehavior) {
      case 'drinking':
        return '水を飲んでいます';
      case 'playing':
        return '遊んでいます';
      case 'resting':
        return '休んでいます';
      case 'shaking':
        return '震えています';
      case 'sniffing':
        return '匂いを嗅いでいます';
      case 'trotting':
        return '小走りしています';
      case 'walking':
        return '歩いています';
      default:
        return '休んでいます';
    }
  }

  /// 現在の行動アイコン
  IconData get currentBehaviorIcon {
    switch (_homeStats.currentBehavior) {
      case 'drinking':
        return Icons.local_drink;
      case 'playing':
        return Icons.sports_tennis;
      case 'resting':
        return Icons.hotel;
      case 'shaking':
        return Icons.vibration;
      case 'sniffing':
        return Icons.search;
      case 'trotting':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.hotel;
    }
  }

  /// 今日の距離（フォーマット済み）
  String get todayDistanceText {
    return '${_homeStats.todayDistanceKm.toStringAsFixed(1)} km';
  }

  /// 今日の活動時間（フォーマット済み）
  String get todayActiveTimeText {
    final minutes = _homeStats.todayActiveMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}時間${remainingMinutes}分';
    } else {
      return '${minutes}分';
    }
  }

  /// 平均ペース（フォーマット済み）
  String get avgPaceText {
    final pace = _homeStats.avgPace;
    final minutes = pace.inMinutes;
    final seconds = pace.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}/km';
  }

  /// 今日のカロリー（フォーマット済み）
  String get todayCaloriesText {
    return '${_homeStats.todayCalories} kcal';
  }

  /// バッテリー情報（フォーマット済み）
  String get batteryText {
    if (_homeStats.batteryPercentage != null) {
      return '${_homeStats.batteryPercentage}%';
    }
    return '-- %';
  }

  /// バッテリー電圧（フォーマット済み）
  String get batteryVoltageText {
    if (_homeStats.batteryVoltage != null) {
      return '${_homeStats.batteryVoltage!.toStringAsFixed(2)}V';
    }
    return '-- V';
  }

  /// 最後の活動時間（フォーマット済み）
  String get lastActivityTimeText {
    if (_homeStats.lastActivityTime == null) {
      return '活動記録なし';
    }
    
    final now = DateTime.now();
    final lastActivity = _homeStats.lastActivityTime!;
    final difference = now.difference(lastActivity);
    
    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  @override
  void dispose() {
    _homeStatsSubscription?.cancel();
    super.dispose();
  }
}