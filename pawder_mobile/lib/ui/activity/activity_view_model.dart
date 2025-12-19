import 'package:flutter/material.dart';

class ActivitySummary {
  ActivitySummary({
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.avgPacePerKm,
  });

  final double totalDistanceKm;
  final int totalDurationMinutes;
  final Duration avgPacePerKm;
}

class ActivityPoint {
  ActivityPoint(this.label, this.valueKm);

  final String label;
  final double valueKm;
}

class ActivityLog {
  ActivityLog({
    required this.title,
    required this.distanceKm,
    required this.pacePerKm,
    required this.durationMinutes,
    required this.dateLabel,
  });

  final String title;
  final double distanceKm;
  final Duration pacePerKm;
  final int durationMinutes;
  final String dateLabel;
}

enum ActivityPeriod { week, month, year, all }

class ActivityViewModel extends ChangeNotifier {
  ActivityViewModel() {
    _loadMock();
  }

  ActivityPeriod _selectedPeriod = ActivityPeriod.week;
  late ActivitySummary summary;
  late List<ActivityPoint> weekly;
  late List<ActivityPoint> monthly;
  late List<ActivityPoint> yearly;
  late List<ActivityLog> logs;

  ActivityPeriod get selectedPeriod => _selectedPeriod;

  List<ActivityPoint> get currentPoints {
    switch (_selectedPeriod) {
      case ActivityPeriod.week:
        return weekly;
      case ActivityPeriod.month:
        return monthly;
      case ActivityPeriod.year:
        return yearly;
      case ActivityPeriod.all:
        return yearly; // すべての場合は年データを表示
    }
  }

  void selectPeriod(ActivityPeriod period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
  }

  void _loadMock() {
    summary = ActivitySummary(
      totalDistanceKm: 28.4,
      totalDurationMinutes: 235,
      avgPacePerKm: const Duration(minutes: 5, seconds: 12),
    );

    weekly = [
      ActivityPoint('月', 3.8),
      ActivityPoint('火', 4.5),
      ActivityPoint('水', 0.0),
      ActivityPoint('木', 6.2),
      ActivityPoint('金', 5.0),
      ActivityPoint('土', 4.9),
      ActivityPoint('日', 4.0),
    ];

    monthly = [
      ActivityPoint('週1', 28.4),
      ActivityPoint('週2', 32.1),
      ActivityPoint('週3', 25.8),
      ActivityPoint('週4', 30.5),
    ];

    yearly = [
      ActivityPoint('1月', 125.0),
      ActivityPoint('2月', 98.5),
      ActivityPoint('3月', 142.3),
      ActivityPoint('4月', 156.8),
      ActivityPoint('5月', 168.2),
      ActivityPoint('6月', 175.5),
      ActivityPoint('7月', 182.1),
      ActivityPoint('8月', 190.3),
      ActivityPoint('9月', 165.4),
      ActivityPoint('10月', 178.9),
      ActivityPoint('11月', 172.6),
      ActivityPoint('12月', 185.2),
    ];

    logs = [
      ActivityLog(
        title: 'イブニングラン',
        distanceKm: 6.2,
        pacePerKm: const Duration(minutes: 5, seconds: 5),
        durationMinutes: 32,
        dateLabel: '今日 18:30',
      ),
      ActivityLog(
        title: 'モーニングジョグ',
        distanceKm: 4.5,
        pacePerKm: const Duration(minutes: 5, seconds: 25),
        durationMinutes: 24,
        dateLabel: '昨日 7:10',
      ),
      ActivityLog(
        title: 'リカバリーウォーク',
        distanceKm: 3.1,
        pacePerKm: const Duration(minutes: 9, seconds: 10),
        durationMinutes: 28,
        dateLabel: '金曜 20:05',
      ),
      ActivityLog(
        title: 'テンポ走',
        distanceKm: 5.8,
        pacePerKm: const Duration(minutes: 4, seconds: 48),
        durationMinutes: 28,
        dateLabel: '木曜 19:00',
      ),
    ];
  }
}

