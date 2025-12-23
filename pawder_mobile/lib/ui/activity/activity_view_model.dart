import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/data_service.dart';
import '../../models/stored_data_models.dart';

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
  final DataService _dataService = DataService();
  
  StreamSubscription<ActivityScreenStats>? _activityStatsSubscription;
  StreamSubscription<List<ActivityChartPoint>>? _chartDataSubscription;
  StreamSubscription<List<ActivityLogEntry>>? _activityLogsSubscription;

  ActivityPeriod _selectedPeriod = ActivityPeriod.week;
  ActivitySummary _summary = ActivitySummary(
    totalDistanceKm: 0.0,
    totalDurationMinutes: 0,
    avgPacePerKm: const Duration(minutes: 10),
  );
  List<ActivityPoint> _currentPoints = [];
  List<ActivityLog> _logs = [];
  bool _isLoading = true;

  ActivityViewModel() {
    _initialize();
  }

  void _initialize() async {
    // データサービスを初期化
    await _dataService.initialize();

    // キャッシュされたデータがあれば即座に表示
    if (_dataService.activityStats != null) {
      _updateSummaryFromStats(_dataService.activityStats!);
    }
    if (_dataService.weeklyData.isNotEmpty) {
      _updatePointsFromChartData(_dataService.weeklyData);
    }
    if (_dataService.activityLogs.isNotEmpty) {
      _updateLogsFromEntries(_dataService.activityLogs);
    }

    // ストリームからの更新を監視
    _activityStatsSubscription = _dataService.activityStatsStream.listen((stats) {
      _updateSummaryFromStats(stats);
      _isLoading = false;
      notifyListeners();
    });

    _chartDataSubscription = _dataService.chartDataStream.listen((chartData) {
      _updatePointsFromChartData(chartData);
      notifyListeners();
    });

    _activityLogsSubscription = _dataService.activityLogsStream.listen((logEntries) {
      _updateLogsFromEntries(logEntries);
      notifyListeners();
    });

    // 初回データロード
    await _dataService.refreshAllData();
    _isLoading = false;
    notifyListeners();
  }

  void _updateSummaryFromStats(ActivityScreenStats stats) {
    _summary = ActivitySummary(
      totalDistanceKm: stats.totalDistanceKm,
      totalDurationMinutes: stats.totalDurationMinutes,
      avgPacePerKm: stats.avgPacePerKm,
    );
  }

  void _updatePointsFromChartData(List<ActivityChartPoint> chartData) {
    _currentPoints = chartData.map((point) => ActivityPoint(
      point.label,
      point.distanceKm,
    )).toList();
  }

  void _updateLogsFromEntries(List<ActivityLogEntry> entries) {
    _logs = entries.map((entry) => ActivityLog(
      title: entry.title,
      distanceKm: entry.distanceKm,
      pacePerKm: entry.pacePerKm,
      durationMinutes: entry.durationMinutes,
      dateLabel: entry.dateLabel,
    )).toList();
  }

  ActivityPeriod get selectedPeriod => _selectedPeriod;
  ActivitySummary get summary => _summary;
  List<ActivityPoint> get currentPoints => _currentPoints;
  List<ActivityLog> get logs => _logs;
  bool get isLoading => _isLoading;

  void selectPeriod(ActivityPeriod period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    
    // 期間に応じてデータを更新
    List<ActivityChartPoint> chartData;
    switch (period) {
      case ActivityPeriod.week:
        chartData = _dataService.weeklyData;
        break;
      case ActivityPeriod.month:
        chartData = _dataService.monthlyData;
        break;
      case ActivityPeriod.year:
      case ActivityPeriod.all:
        chartData = _dataService.yearlyData;
        break;
    }
    
    _updatePointsFromChartData(chartData);
    notifyListeners();
  }

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
    _activityStatsSubscription?.cancel();
    _chartDataSubscription?.cancel();
    _activityLogsSubscription?.cancel();
    super.dispose();
  }
}

