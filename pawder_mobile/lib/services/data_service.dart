import 'dart:async';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/stored_data_models.dart';

/// データサービスクラス
/// データベースからデータを取得し、UI画面に提供する
/// リアルタイムで更新を通知する
class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  // ストリーム
  final StreamController<HomeScreenStats> _homeStatsController = 
      StreamController<HomeScreenStats>.broadcast();
  final StreamController<ActivityScreenStats> _activityStatsController = 
      StreamController<ActivityScreenStats>.broadcast();
  final StreamController<List<ActivityChartPoint>> _chartDataController = 
      StreamController<List<ActivityChartPoint>>.broadcast();
  final StreamController<List<ActivityLogEntry>> _activityLogsController = 
      StreamController<List<ActivityLogEntry>>.broadcast();

  // キャッシュされたデータ
  HomeScreenStats? _homeStats;
  ActivityScreenStats? _activityStats;
  List<ActivityChartPoint> _weeklyData = [];
  List<ActivityChartPoint> _monthlyData = [];
  List<ActivityChartPoint> _yearlyData = [];
  List<ActivityLogEntry> _activityLogs = [];

  // タイマー
  Timer? _refreshTimer;

  /// ストリーム取得
  Stream<HomeScreenStats> get homeStatsStream => _homeStatsController.stream;
  Stream<ActivityScreenStats> get activityStatsStream => _activityStatsController.stream;
  Stream<List<ActivityChartPoint>> get chartDataStream => _chartDataController.stream;
  Stream<List<ActivityLogEntry>> get activityLogsStream => _activityLogsController.stream;

  /// キャッシュされたデータ取得
  HomeScreenStats? get homeStats => _homeStats;
  ActivityScreenStats? get activityStats => _activityStats;
  List<ActivityChartPoint> get weeklyData => _weeklyData;
  List<ActivityChartPoint> get monthlyData => _monthlyData;
  List<ActivityChartPoint> get yearlyData => _yearlyData;
  List<ActivityLogEntry> get activityLogs => _activityLogs;

  /// データサービス初期化
  Future<void> initialize() async {
    // 初期データをロード
    await refreshAllData();
    
    // 定期的にデータを更新（30秒間隔）
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshAllData();
    });
  }

  /// 全てのデータを更新
  Future<void> refreshAllData() async {
    try {
      await Future.wait([
        _refreshHomeStats(),
        _refreshActivityStats(),
        _refreshChartData(),
        _refreshActivityLogs(),
      ]);
      
      // UIに更新を通知
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  /// ホーム画面統計データを更新
  Future<void> _refreshHomeStats() async {
    try {
      // 最新の行動データを取得
      final latestBehavior = await _databaseHelper.getLatestBehavior();
      final latestBattery = await _databaseHelper.getLatestBatteryData();
      final todayBehaviors = await _databaseHelper.getTodayBehaviorData();

      // 今日の統計を計算
      double todayDistance = 0.0;
      int todayActiveMinutes = 0;
      int totalActiveSeconds = 0;
      DateTime? lastActivityTime;

      for (final behavior in todayBehaviors) {
        final behaviorType = behavior['behavior'] as String;
        final durationSeconds = behavior['duration_seconds'] as int? ?? 0;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(behavior['timestamp'] as int);

        if (behaviorType == 'walking' || behaviorType == 'trotting') {
          todayActiveMinutes += (durationSeconds / 60).round();
          totalActiveSeconds += durationSeconds;
          lastActivityTime ??= timestamp;
          
          if (behaviorType == 'walking') {
            todayDistance += (durationSeconds / 3600) * 3.0; // 3km/h
          } else if (behaviorType == 'trotting') {
            todayDistance += (durationSeconds / 3600) * 6.0; // 6km/h
          }
        }
      }

      // 平均ペースを計算
      Duration avgPace = const Duration(minutes: 10);
      if (todayDistance > 0 && totalActiveSeconds > 0) {
        final paceSeconds = (totalActiveSeconds / todayDistance).round();
        avgPace = Duration(seconds: paceSeconds);
      }

      // カロリーを計算（大型犬の場合、1km当たり約70カロリーと仮定）
      final todayCalories = (todayDistance * 70).round();

      final homeStats = HomeScreenStats(
        currentBehavior: latestBehavior?['behavior'] as String? ?? 'resting',
        batteryPercentage: latestBattery?['percentage'] as int?,
        batteryVoltage: latestBattery?['voltage'] as double?,
        todayDistanceKm: todayDistance,
        todayActiveMinutes: todayActiveMinutes,
        avgPace: avgPace,
        todayCalories: todayCalories,
        lastActivityTime: lastActivityTime,
      );

      _homeStats = homeStats;
      _homeStatsController.add(homeStats);
    } catch (e) {
      print('Error refreshing home stats: $e');
    }
  }

  /// アクティビティ画面統計データを更新
  Future<void> _refreshActivityStats() async {
    try {
      // 週間データを取得
      final weeklyData = await _databaseHelper.getWeeklyActivityData();
      
      double totalDistance = 0.0;
      int totalMinutes = 0;

      for (final dayData in weeklyData) {
        final distance = dayData['distanceKm'] as double? ?? 0.0;
        final minutes = dayData['totalActiveMinutes'] as int? ?? 0;
        
        totalDistance += distance;
        totalMinutes += minutes;
      }

      // 平均ペースを計算
      Duration avgPace = const Duration(minutes: 10);
      if (totalDistance > 0 && totalMinutes > 0) {
        final paceSeconds = ((totalMinutes * 60) / totalDistance).round();
        avgPace = Duration(seconds: paceSeconds);
      }

      final activityStats = ActivityScreenStats(
        totalDistanceKm: totalDistance,
        totalDurationMinutes: totalMinutes,
        avgPacePerKm: avgPace,
      );

      _activityStats = activityStats;
      _activityStatsController.add(activityStats);
    } catch (e) {
      print('Error refreshing activity stats: $e');
    }
  }

  /// チャートデータを更新
  Future<void> _refreshChartData() async {
    try {
      // 週間データ
      final weeklyRawData = await _databaseHelper.getWeeklyActivityData();
      _weeklyData = weeklyRawData.map((data) => ActivityChartPoint.fromMap(data)).toList();

      // 月間データ
      final monthlyRawData = await _databaseHelper.getMonthlyActivityData();
      _monthlyData = monthlyRawData.map((data) => ActivityChartPoint(
        label: data['month'] ?? '',
        distanceKm: data['distanceKm'] as double? ?? 0.0,
        activeMinutes: data['totalActiveMinutes'] as int? ?? 0,
      )).toList();

      // 年間データ
      final yearlyRawData = await _databaseHelper.getYearlyActivityData();
      _yearlyData = yearlyRawData.map((data) => ActivityChartPoint(
        label: data['month'] ?? '',
        distanceKm: data['distanceKm'] as double? ?? 0.0,
        activeMinutes: data['totalActiveMinutes'] as int? ?? 0,
      )).toList();

      _chartDataController.add(_weeklyData);
    } catch (e) {
      print('Error refreshing chart data: $e');
    }
  }

  /// アクティビティログを更新
  Future<void> _refreshActivityLogs() async {
    try {
      final logsRawData = await _databaseHelper.getRecentActivityLogs(limit: 10);
      _activityLogs = logsRawData.map((data) => ActivityLogEntry.fromMap(data)).toList();
      
      _activityLogsController.add(_activityLogs);
    } catch (e) {
      print('Error refreshing activity logs: $e');
    }
  }

  /// 指定期間のチャートデータを取得
  List<ActivityChartPoint> getChartDataForPeriod(String period) {
    switch (period) {
      case 'week':
        return _weeklyData;
      case 'month':
        return _monthlyData;
      case 'year':
        return _yearlyData;
      default:
        return _weeklyData;
    }
  }

  /// 新しいデータが追加された時の通知
  void notifyDataChanged() {
    // データを即座に更新
    refreshAllData();
  }

  /// 強制的にデータを再読み込み
  Future<void> forceRefresh() async {
    await refreshAllData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _homeStatsController.close();
    _activityStatsController.close();
    _chartDataController.close();
    _activityLogsController.close();
    super.dispose();
  }
}