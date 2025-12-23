import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// データベースヘルパークラス
/// 犬の行動データと関連する統計情報を管理
class DatabaseHelper {
  static const _databaseName = 'pawder_database.db';
  static const _databaseVersion = 1;

  // テーブル名
  static const _tableDogBehaviors = 'dog_behaviors';
  static const _tableBatteryData = 'battery_data';
  static const _tableDailySummary = 'daily_summary';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static DatabaseHelper get instance => _instance;

  static Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// データベース初期化
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// データベース作成
  Future<void> _onCreate(Database db, int version) async {
    // 犬の行動データテーブル
    await db.execute('''
      CREATE TABLE $_tableDogBehaviors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        behavior TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        battery_voltage REAL,
        battery_percentage INTEGER,
        duration_seconds INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // バッテリーデータテーブル（履歴追跡用）
    await db.execute('''
      CREATE TABLE $_tableBatteryData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voltage REAL NOT NULL,
        percentage INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 日別サマリーテーブル（集計データ）
    await db.execute('''
      CREATE TABLE $_tableDailySummary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        total_walking_minutes INTEGER DEFAULT 0,
        total_playing_minutes INTEGER DEFAULT 0,
        total_sniffing_minutes INTEGER DEFAULT 0,
        total_drinking_count INTEGER DEFAULT 0,
        total_resting_minutes INTEGER DEFAULT 0,
        total_trotting_minutes INTEGER DEFAULT 0,
        total_shaking_count INTEGER DEFAULT 0,
        distance_km REAL DEFAULT 0.0,
        calories INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // インデックス作成
    await db.execute('CREATE INDEX idx_behaviors_timestamp ON $_tableDogBehaviors(timestamp)');
    await db.execute('CREATE INDEX idx_behaviors_behavior ON $_tableDogBehaviors(behavior)');
    await db.execute('CREATE INDEX idx_battery_timestamp ON $_tableBatteryData(timestamp)');
    await db.execute('CREATE INDEX idx_daily_date ON $_tableDailySummary(date)');
  }

  /// データベースアップグレード
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 将来のバージョンアップ時に使用
  }

  /// 犬の行動データを挿入
  Future<int> insertBehaviorData(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_tableDogBehaviors, data);
  }

  /// バッテリーデータを挿入
  Future<int> insertBatteryData(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(_tableBatteryData, data);
  }

  /// 最新の行動データを取得
  Future<Map<String, dynamic>?> getLatestBehavior() async {
    final db = await database;
    final results = await db.query(
      _tableDogBehaviors,
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// 最新のバッテリーデータを取得
  Future<Map<String, dynamic>?> getLatestBatteryData() async {
    final db = await database;
    final results = await db.query(
      _tableBatteryData,
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// 指定期間の行動データを取得
  Future<List<Map<String, dynamic>>> getBehaviorDataByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    return await db.query(
      _tableDogBehaviors,
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
  }

  /// 今日の行動データを取得
  Future<List<Map<String, dynamic>>> getTodayBehaviorData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await getBehaviorDataByPeriod(startOfDay, endOfDay);
  }

  /// 週別の活動データを取得（アクティビティ画面用）
  Future<List<Map<String, dynamic>>> getWeeklyActivityData() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekData = <Map<String, dynamic>>[];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final behaviors = await getBehaviorDataByPeriod(startOfDay, endOfDay);
      
      double distanceKm = 0.0;
      int walkingMinutes = 0;
      int trottingMinutes = 0;
      
      for (final behavior in behaviors) {
        final behaviorType = behavior['behavior'] as String;
        final durationSeconds = (behavior['duration_seconds'] as int?) ?? 0;
        
        if (behaviorType == 'walking') {
          walkingMinutes += (durationSeconds / 60).round();
          // 仮定: 歩行時の平均速度を3km/hとして距離を計算
          distanceKm += (durationSeconds / 3600) * 3.0;
        } else if (behaviorType == 'trotting') {
          trottingMinutes += (durationSeconds / 60).round();
          // 仮定: 小走り時の平均速度を6km/hとして距離を計算
          distanceKm += (durationSeconds / 3600) * 6.0;
        }
      }

      weekData.add({
        'date': startOfDay.toIso8601String().substring(0, 10),
        'dayOfWeek': _getDayOfWeekJapanese(date.weekday),
        'distanceKm': distanceKm,
        'walkingMinutes': walkingMinutes,
        'trottingMinutes': trottingMinutes,
        'totalActiveMinutes': walkingMinutes + trottingMinutes,
      });
    }

    return weekData;
  }

  /// 月別の活動データを取得
  Future<List<Map<String, dynamic>>> getMonthlyActivityData() async {
    final now = DateTime.now();
    final monthData = <Map<String, dynamic>>[];

    for (int i = 3; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
      final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 1);
      
      final behaviors = await getBehaviorDataByPeriod(startOfMonth, endOfMonth);
      
      double distanceKm = 0.0;
      int totalActiveMinutes = 0;
      
      for (final behavior in behaviors) {
        final behaviorType = behavior['behavior'] as String;
        final durationSeconds = (behavior['duration_seconds'] as int?) ?? 0;
        
        if (behaviorType == 'walking') {
          totalActiveMinutes += (durationSeconds / 60).round();
          distanceKm += (durationSeconds / 3600) * 3.0;
        } else if (behaviorType == 'trotting') {
          totalActiveMinutes += (durationSeconds / 60).round();
          distanceKm += (durationSeconds / 3600) * 6.0;
        }
      }

      monthData.add({
        'month': '${targetDate.month}月',
        'year': targetDate.year,
        'distanceKm': distanceKm,
        'totalActiveMinutes': totalActiveMinutes,
      });
    }

    return monthData;
  }

  /// 年別の活動データを取得
  Future<List<Map<String, dynamic>>> getYearlyActivityData() async {
    final now = DateTime.now();
    final yearData = <Map<String, dynamic>>[];

    for (int month = 1; month <= 12; month++) {
      final startOfMonth = DateTime(now.year, month, 1);
      final endOfMonth = DateTime(now.year, month + 1, 1);
      
      final behaviors = await getBehaviorDataByPeriod(startOfMonth, endOfMonth);
      
      double distanceKm = 0.0;
      int totalActiveMinutes = 0;
      
      for (final behavior in behaviors) {
        final behaviorType = behavior['behavior'] as String;
        final durationSeconds = (behavior['duration_seconds'] as int?) ?? 0;
        
        if (behaviorType == 'walking') {
          totalActiveMinutes += (durationSeconds / 60).round();
          distanceKm += (durationSeconds / 3600) * 3.0;
        } else if (behaviorType == 'trotting') {
          totalActiveMinutes += (durationSeconds / 60).round();
          distanceKm += (durationSeconds / 3600) * 6.0;
        }
      }

      yearData.add({
        'month': '${month}月',
        'monthNumber': month,
        'distanceKm': distanceKm,
        'totalActiveMinutes': totalActiveMinutes,
      });
    }

    return yearData;
  }

  /// 最近のアクティビティログを取得
  Future<List<Map<String, dynamic>>> getRecentActivityLogs({int limit = 10}) async {
    final db = await database;
    
    // 歩行またはトロット行動のデータを取得
    final results = await db.query(
      _tableDogBehaviors,
      where: 'behavior IN (?, ?) AND duration_seconds > 0',
      whereArgs: ['walking', 'trotting'],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.map((behavior) {
      final behaviorType = behavior['behavior'] as String;
      final durationSeconds = (behavior['duration_seconds'] as int?) ?? 0;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(behavior['timestamp'] as int);
      
      double distanceKm = 0.0;
      if (behaviorType == 'walking') {
        distanceKm = (durationSeconds / 3600) * 3.0;
      } else if (behaviorType == 'trotting') {
        distanceKm = (durationSeconds / 3600) * 6.0;
      }
      
      final pacePerKm = distanceKm > 0 
          ? Duration(seconds: (durationSeconds / distanceKm).round())
          : const Duration(minutes: 10);

      return {
        ...behavior,
        'distanceKm': distanceKm,
        'pacePerKm': pacePerKm.inSeconds,
        'formattedDate': _formatDateTime(timestamp),
      };
    }).toList();
  }

  /// データベースをクリア（テスト用）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableDogBehaviors);
    await db.delete(_tableBatteryData);
    await db.delete(_tableDailySummary);
  }

  /// データベースを閉じる
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 曜日を日本語で取得
  String _getDayOfWeekJapanese(int weekday) {
    switch (weekday) {
      case 1: return '月';
      case 2: return '火';
      case 3: return '水';
      case 4: return '木';
      case 5: return '金';
      case 6: return '土';
      case 7: return '日';
      default: return '';
    }
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return '今日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (targetDate == yesterday) {
      return '昨日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}