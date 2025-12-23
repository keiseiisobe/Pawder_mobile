/// データベースに保存される犬の行動データモデル
class StoredDogBehaviorData {
  final int? id;
  final String behavior;
  final DateTime timestamp;
  final double? batteryVoltage;
  final int? batteryPercentage;
  final int durationSeconds;
  final DateTime createdAt;

  StoredDogBehaviorData({
    this.id,
    required this.behavior,
    required this.timestamp,
    this.batteryVoltage,
    this.batteryPercentage,
    this.durationSeconds = 0,
    required this.createdAt,
  });

  /// データベースレコードから作成
  factory StoredDogBehaviorData.fromMap(Map<String, dynamic> map) {
    return StoredDogBehaviorData(
      id: map['id'] as int?,
      behavior: map['behavior'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      batteryVoltage: map['battery_voltage'] as double?,
      batteryPercentage: map['battery_percentage'] as int?,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// データベース挿入用のマップに変換
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'behavior': behavior,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'battery_voltage': batteryVoltage,
      'battery_percentage': batteryPercentage,
      'duration_seconds': durationSeconds,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}

/// バッテリーデータモデル
class StoredBatteryData {
  final int? id;
  final double voltage;
  final int percentage;
  final DateTime timestamp;
  final DateTime createdAt;

  StoredBatteryData({
    this.id,
    required this.voltage,
    required this.percentage,
    required this.timestamp,
    required this.createdAt,
  });

  factory StoredBatteryData.fromMap(Map<String, dynamic> map) {
    return StoredBatteryData(
      id: map['id'] as int?,
      voltage: map['voltage'] as double,
      percentage: map['percentage'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'voltage': voltage,
      'percentage': percentage,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}

/// ホーム画面用の統計データモデル
class HomeScreenStats {
  final String currentBehavior;
  final int? batteryPercentage;
  final double? batteryVoltage;
  final double todayDistanceKm;
  final int todayActiveMinutes;
  final Duration avgPace;
  final int todayCalories;
  final DateTime? lastActivityTime;

  HomeScreenStats({
    required this.currentBehavior,
    this.batteryPercentage,
    this.batteryVoltage,
    required this.todayDistanceKm,
    required this.todayActiveMinutes,
    required this.avgPace,
    required this.todayCalories,
    this.lastActivityTime,
  });

  factory HomeScreenStats.empty() {
    return HomeScreenStats(
      currentBehavior: 'resting',
      todayDistanceKm: 0.0,
      todayActiveMinutes: 0,
      avgPace: const Duration(minutes: 10),
      todayCalories: 0,
    );
  }
}

/// アクティビティ画面用の統計データモデル
class ActivityScreenStats {
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final Duration avgPacePerKm;

  ActivityScreenStats({
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.avgPacePerKm,
  });

  factory ActivityScreenStats.empty() {
    return ActivityScreenStats(
      totalDistanceKm: 0.0,
      totalDurationMinutes: 0,
      avgPacePerKm: const Duration(minutes: 10),
    );
  }
}

/// アクティビティポイントデータ（グラフ用）
class ActivityChartPoint {
  final String label;
  final double distanceKm;
  final int activeMinutes;

  ActivityChartPoint({
    required this.label,
    required this.distanceKm,
    required this.activeMinutes,
  });

  factory ActivityChartPoint.fromMap(Map<String, dynamic> map) {
    return ActivityChartPoint(
      label: map['dayOfWeek'] ?? map['month'] ?? '',
      distanceKm: map['distanceKm'] as double? ?? 0.0,
      activeMinutes: map['totalActiveMinutes'] as int? ?? 0,
    );
  }
}

/// アクティビティログデータ（最近の活動履歴用）
class ActivityLogEntry {
  final String title;
  final double distanceKm;
  final Duration pacePerKm;
  final int durationMinutes;
  final String dateLabel;
  final String behavior;

  ActivityLogEntry({
    required this.title,
    required this.distanceKm,
    required this.pacePerKm,
    required this.durationMinutes,
    required this.dateLabel,
    required this.behavior,
  });

  factory ActivityLogEntry.fromMap(Map<String, dynamic> map) {
    final behavior = map['behavior'] as String;
    final durationSeconds = map['duration_seconds'] as int? ?? 0;
    final paceSeconds = map['pacePerKm'] as int? ?? 600; // デフォルト10分/km

    return ActivityLogEntry(
      title: _getTitleFromBehavior(behavior),
      distanceKm: map['distanceKm'] as double? ?? 0.0,
      pacePerKm: Duration(seconds: paceSeconds),
      durationMinutes: (durationSeconds / 60).round(),
      dateLabel: map['formattedDate'] as String? ?? '',
      behavior: behavior,
    );
  }

  static String _getTitleFromBehavior(String behavior) {
    switch (behavior) {
      case 'walking':
        return 'ウォーキング';
      case 'trotting':
        return 'ランニング';
      case 'playing':
        return 'プレイタイム';
      default:
        return '活動';
    }
  }
}

/// 行動継続時間追跡用のヘルパークラス
class BehaviorTracker {
  String? _currentBehavior;
  DateTime? _behaviorStartTime;
  
  String? get currentBehavior => _currentBehavior;
  DateTime? get behaviorStartTime => _behaviorStartTime;
  
  /// 新しい行動を開始
  void startBehavior(String behavior) {
    _currentBehavior = behavior;
    _behaviorStartTime = DateTime.now();
  }
  
  /// 現在の行動を終了し、継続時間を計算
  int? endCurrentBehavior() {
    if (_behaviorStartTime == null) return null;
    
    final duration = DateTime.now().difference(_behaviorStartTime!);
    _currentBehavior = null;
    _behaviorStartTime = null;
    
    return duration.inSeconds;
  }
  
  /// 現在の行動の継続時間を取得（秒）
  int getCurrentBehaviorDuration() {
    if (_behaviorStartTime == null) return 0;
    return DateTime.now().difference(_behaviorStartTime!).inSeconds;
  }
  
  /// 行動が変更されたかどうかをチェック
  bool isBehaviorChanged(String newBehavior) {
    return _currentBehavior != newBehavior;
  }
}