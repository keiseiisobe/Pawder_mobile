import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../services/data_service.dart';
import '../../models/stored_data_models.dart';

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
  final DataService _dataService = DataService();
  
  StreamSubscription<HomeScreenStats>? _homeStatsSubscription;

  // 静的データ
  late DogProfile dogProfile;
  late List<AchievementBadge> badges;
  late List<RecentWalk> recentWalks;

  // 動的データ
  TodayStats _todayStats = TodayStats(
    distanceKm: 0.0,
    durationMinutes: 0,
    avgPacePerKm: const Duration(minutes: 10),
    calories: 0,
    routePolyline: const [],
  );
  String _currentBehavior = 'resting';
  int? _batteryPercentage;
  double? _batteryVoltage;
  bool _isLoading = true;

  HomeViewModel() {
    _initialize();
    _loadStaticData();
  }

  void _initialize() async {
    // データサービスを初期化
    await _dataService.initialize();

    // キャッシュされたデータがあれば即座に表示
    if (_dataService.homeStats != null) {
      _updateFromHomeStats(_dataService.homeStats!);
    }

    // ストリームからの更新を監視
    _homeStatsSubscription = _dataService.homeStatsStream.listen((stats) {
      _updateFromHomeStats(stats);
      _isLoading = false;
      notifyListeners();
    });

    // 初回データロード
    await _dataService.refreshAllData();
    _isLoading = false;
    notifyListeners();
  }

  void _updateFromHomeStats(HomeScreenStats stats) {
    _currentBehavior = stats.currentBehavior;
    _batteryPercentage = stats.batteryPercentage;
    _batteryVoltage = stats.batteryVoltage;
    
    _todayStats = TodayStats(
      distanceKm: stats.todayDistanceKm,
      durationMinutes: stats.todayActiveMinutes,
      avgPacePerKm: stats.avgPace,
      calories: stats.todayCalories,
      routePolyline: _generateMockRoute(), // 実際のGPSルートが利用可能になるまではモックデータ
    );
  }

  void _loadStaticData() {
    dogProfile = DogProfile(
      name: 'レッカー',
      ageYears: 4,
      avatarColor: const Color(0xFF1C1F2B),
    );

    badges = [
      AchievementBadge(
        name: '初回散歩',
        description: '初めての散歩を完了しました',
        icon: Icons.directions_walk,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AchievementBadge(
        name: 'アクティブ',
        description: '7日連続で散歩しました',
        icon: Icons.local_fire_department,
        isUnlocked: _todayStats.durationMinutes > 60, // 動的にバッジの解除状態を判定
        unlockedDate: _todayStats.durationMinutes > 60 ? DateTime.now().subtract(const Duration(days: 7)) : null,
      ),
      AchievementBadge(
        name: '距離の達人',
        description: '10km歩きました',
        icon: Icons.emoji_events,
        isUnlocked: _todayStats.distanceKm >= 10.0,
        unlockedDate: _todayStats.distanceKm >= 10.0 ? DateTime.now() : null,
      ),
    ];

    recentWalks = _generateRecentWalks();
  }

  List<RecentWalk> _generateRecentWalks() {
    return [
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

  List<LatLng> _generateMockRoute() {
    // 実際のGPSルートが利用可能になるまでの仮のルート
    return const [
      LatLng(35.681236, 139.767125),
      LatLng(35.682, 139.77),
      LatLng(35.683, 139.772),
      LatLng(35.684, 139.769),
    ];
  }

  // Getters
  TodayStats get todayStats => _todayStats;
  String get currentBehavior => _currentBehavior;
  int? get batteryPercentage => _batteryPercentage;
  double? get batteryVoltage => _batteryVoltage;
  bool get isLoading => _isLoading;

  /// 手動でデータを更新
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await _dataService.forceRefresh();
    
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _homeStatsSubscription?.cancel();
    super.dispose();
  }
}