import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/dog_status_model.dart';
import '../../services/bluetooth_service.dart';

class DogProfile {
  DogProfile({
    required this.name,
    required this.ageYears,
    required this.avatarColor,
  });

  final String name;
  final int ageYears;
  final Color avatarColor;
}

class TodayActivity {
  TodayActivity({
    required this.distanceKm,
    required this.durationMinutes,
    required this.calories,
    required this.routePolyline,
  });

  final double distanceKm;
  final int durationMinutes;
  final int calories;
  final List<LatLng> routePolyline;
}

class AchievementBadge {
  AchievementBadge({
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });

  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
}

class TodayStats {
  TodayStats({
    required this.distanceKm,
    required this.durationMinutes,
    required this.avgPacePerKm,
    required this.calories,
    required this.routePolyline,
  });

  final double distanceKm;
  final int durationMinutes;
  final Duration avgPacePerKm;
  final int calories;
  final List<LatLng> routePolyline;
}

enum WalkViewType { route, smell, play }

class RecentWalk {
  RecentWalk({
    required this.date,
    required this.routePolyline,
    required this.smellPoints,
    required this.playPoints,
  });

  final DateTime date;
  final List<LatLng> routePolyline;
  final List<LatLng> smellPoints;
  final List<LatLng> playPoints;
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _loadMockData();
    _bluetoothService = BluetoothService();
    _initializeBluetooth();
  }

  late BluetoothService _bluetoothService;
  WalkViewType _selectedWalkView = WalkViewType.route;
  late DogProfile dogProfile;
  late TodayStats todayStats;
  late List<AchievementBadge> badges;
  late List<RecentWalk> recentWalks;

  // Bluetooth関連のプロパティ
  DogStatusModel? _currentDogStatus;
  DeviceConnectionModel _connectionModel = DeviceConnectionModel(isConnected: false);

  // Getters
  WalkViewType get selectedWalkView => _selectedWalkView;
  BluetoothService get bluetoothService => _bluetoothService;
  DogStatusModel? get currentDogStatus => _currentDogStatus;
  DeviceConnectionModel get connectionModel => _connectionModel;

  Future<void> _initializeBluetooth() async {
    try {
      await _bluetoothService.initialize();
      
      // Bluetooth サービスの状態変更を監視
      _bluetoothService.addListener(_onBluetoothServiceChanged);
    } catch (e) {
      print('Bluetooth initialization error: $e');
    }
  }

  void _onBluetoothServiceChanged() {
    // BLE デバイスからのデータを取得
    final dogStatusData = _bluetoothService.currentDogStatus;
    if (dogStatusData != null) {
      _currentDogStatus = DogStatusModel(
        behavior: dogStatusData.behavior,
        batteryLevel: dogStatusData.battery,
      );
    }

    // デバイス接続状態を更新
    _connectionModel = DeviceConnectionModel(
      deviceId: _bluetoothService.connectedDevice?.remoteId.str,
      deviceName: _bluetoothService.connectedDevice?.platformName,
      isConnected: _bluetoothService.connectedDevice != null,
      connectionStatus: _bluetoothService.connectionStatus,
    );

    notifyListeners();
  }

  void selectWalkView(WalkViewType type) {
    if (_selectedWalkView == type) return;
    _selectedWalkView = type;
    notifyListeners();
  }

  Future<void> scanForDevices() async {
    await _bluetoothService.startScanning();
  }

  Future<void> connectToDevice(String deviceId) async {
    final devices = _bluetoothService.availableDevices;
    final device = devices.firstWhere(
      (d) => d.remoteId.str == deviceId,
      orElse: () => throw Exception('デバイスが見つかりません'),
    );
    
    await _bluetoothService.connectToDevice(device);
  }

  Future<void> disconnectDevice() async {
    await _bluetoothService.disconnect();
  }

  @override
  void dispose() {
    _bluetoothService.removeListener(_onBluetoothServiceChanged);
    _bluetoothService.dispose();
    super.dispose();
  }

  void _loadMockData() {
    dogProfile = DogProfile(
      name: 'ロック',
      ageYears: 4,
      avatarColor: const Color(0xFF1C1F2B),
    );

    todayStats = TodayStats(
      distanceKm: 4.2,
      durationMinutes: 55,
      avgPacePerKm: const Duration(minutes: 5, seconds: 12),
      calories: 310,
      routePolyline: const [
        LatLng(35.681236, 139.767125),
        LatLng(35.682, 139.77),
        LatLng(35.683, 139.772),
        LatLng(35.684, 139.769),
      ],
    );

    badges = [
      AchievementBadge(
        name: '初めての散歩',
        description: '最初の散歩を完了',
        icon: Icons.directions_walk,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AchievementBadge(
        name: '週間チャレンジ',
        description: '1週間連続で散歩',
        icon: Icons.calendar_today,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      AchievementBadge(
        name: '距離マスター',
        description: '累計100km達成',
        icon: Icons.straighten,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AchievementBadge(
        name: '早起きチャンピオン',
        description: '朝6時前に散歩',
        icon: Icons.wb_sunny,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AchievementBadge(
        name: '月間チャレンジ',
        description: '1ヶ月連続で散歩',
        icon: Icons.event,
        isUnlocked: false,
      ),
      AchievementBadge(
        name: 'マラソン達成',
        description: '累計42.195km達成',
        icon: Icons.emoji_events,
        isUnlocked: false,
      ),
    ];

    recentWalks = [
      RecentWalk(
        date: DateTime.now().subtract(const Duration(days: 1)),
        routePolyline: const [
          LatLng(35.681236, 139.767125),
          LatLng(35.682, 139.77),
          LatLng(35.683, 139.772),
          LatLng(35.684, 139.769),
        ],
        smellPoints: const [
          LatLng(35.682, 139.77),
          LatLng(35.683, 139.772),
        ],
        playPoints: const [
          LatLng(35.684, 139.769),
        ],
      ),
      RecentWalk(
        date: DateTime.now().subtract(const Duration(days: 2)),
        routePolyline: const [
          LatLng(35.680, 139.765),
          LatLng(35.681, 139.768),
          LatLng(35.682, 139.771),
        ],
        smellPoints: const [
          LatLng(35.681, 139.768),
        ],
        playPoints: const [
          LatLng(35.682, 139.771),
        ],
      ),
    ];
  }
}


