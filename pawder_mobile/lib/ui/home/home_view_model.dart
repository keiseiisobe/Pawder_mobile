import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
  }

  WalkViewType _selectedWalkView = WalkViewType.route;
  late DogProfile dogProfile;
  late TodayStats todayStats;
  late List<AchievementBadge> badges;
  late List<RecentWalk> recentWalks;

  WalkViewType get selectedWalkView => _selectedWalkView;

  void selectWalkView(WalkViewType type) {
    if (_selectedWalkView == type) return;
    _selectedWalkView = type;
    notifyListeners();
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


