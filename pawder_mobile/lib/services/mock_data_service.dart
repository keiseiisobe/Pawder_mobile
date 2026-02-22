import '../models/walk_activity.dart';
import '../models/achievement.dart';
import '../models/dog_profile.dart';
import '../models/territory.dart';
import '../models/health_data.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // 犬のプロフィール
  DogProfile getDogProfile() {
    return DogProfile(
      name: 'ポチ',
      breed: '柴犬',
      ageYears: 3,
      weightKg: 10.5,
      avatarEmoji: '🐕',
      unlockedAccessories: ['🎀', '🎩', '👑', '🦴', '⚽'],
      currentAccessory: '🎀',
      level: 12,
      totalWalks: 247,
      totalDistanceKm: 312.5,
      diversityScore: 150,
    );
  }

  // 散歩履歴
  List<WalkActivity> getWalkHistory() {
    final now = DateTime.now();
    return [
      WalkActivity(
        id: '1',
        date: now.subtract(const Duration(hours: 2)),
        distanceKm: 2.3,
        durationMinutes: 35,
        route: _generateMockRoute(35.6762, 139.6503, 20),
        markings: [
          MarkingPoint(
            latitude: 35.6765,
            longitude: 139.6505,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
            type: 'marking',
          ),
          MarkingPoint(
            latitude: 35.6770,
            longitude: 139.6510,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
            type: 'favorite',
          ),
        ],
        sniffingPoints: [
          SniffingPoint(
            latitude: 35.6768,
            longitude: 139.6507,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 25)),
            durationSeconds: 45,
            foundItem: '🎩',
          ),
        ],
        moodEmoji: '😊',
        caloriesBurned: 92,
      ),
      WalkActivity(
        id: '2',
        date: now.subtract(const Duration(days: 1, hours: 8)),
        distanceKm: 3.5,
        durationMinutes: 52,
        route: _generateMockRoute(35.6762, 139.6503, 30),
        markings: [
          MarkingPoint(
            latitude: 35.6780,
            longitude: 139.6520,
            timestamp: now.subtract(const Duration(days: 1, hours: 8, minutes: 40)),
            type: 'marking',
          ),
        ],
        sniffingPoints: [
          SniffingPoint(
            latitude: 35.6775,
            longitude: 139.6515,
            timestamp: now.subtract(const Duration(days: 1, hours: 8, minutes: 30)),
            durationSeconds: 60,
          ),
        ],
        moodEmoji: '🤩',
        caloriesBurned: 140,
      ),
      WalkActivity(
        id: '3',
        date: now.subtract(const Duration(days: 2, hours: 9)),
        distanceKm: 1.8,
        durationMinutes: 28,
        route: _generateMockRoute(35.6762, 139.6503, 15),
        markings: [],
        sniffingPoints: [
          SniffingPoint(
            latitude: 35.6765,
            longitude: 139.6508,
            timestamp: now.subtract(const Duration(days: 2, hours: 9, minutes: 15)),
            durationSeconds: 30,
            foundItem: '🦴',
          ),
        ],
        moodEmoji: '😌',
        caloriesBurned: 72,
      ),
      WalkActivity(
        id: '4',
        date: now.subtract(const Duration(days: 3, hours: 7)),
        distanceKm: 4.2,
        durationMinutes: 65,
        route: _generateMockRoute(35.6762, 139.6503, 40),
        markings: [
          MarkingPoint(
            latitude: 35.6790,
            longitude: 139.6530,
            timestamp: now.subtract(const Duration(days: 3, hours: 7, minutes: 50)),
            type: 'special',
          ),
        ],
        sniffingPoints: [],
        moodEmoji: '😄',
        caloriesBurned: 168,
      ),
      WalkActivity(
        id: '5',
        date: now.subtract(const Duration(days: 4, hours: 8)),
        distanceKm: 2.7,
        durationMinutes: 42,
        route: _generateMockRoute(35.6762, 139.6503, 25),
        markings: [],
        sniffingPoints: [
          SniffingPoint(
            latitude: 35.6770,
            longitude: 139.6512,
            timestamp: now.subtract(const Duration(days: 4, hours: 8, minutes: 20)),
            durationSeconds: 55,
            foundItem: '👑',
          ),
        ],
        moodEmoji: '😊',
        caloriesBurned: 108,
      ),
    ];
  }

  // アチーブメント
  List<Achievement> getAchievements() {
    final now = DateTime.now();
    return [
      Achievement(
        id: '1',
        title: '初めての散歩',
        description: '最初の一歩を踏み出した！',
        iconEmoji: '🐾',
        unlockedDate: now.subtract(const Duration(days: 180)),
        isUnlocked: true,
        progress: 1,
        target: 1,
        category: AchievementCategory.special,
      ),
      Achievement(
        id: '2',
        title: '100km達成',
        description: '累計100kmを歩いた！',
        iconEmoji: '🏆',
        unlockedDate: now.subtract(const Duration(days: 60)),
        isUnlocked: true,
        progress: 100,
        target: 100,
        category: AchievementCategory.distance,
      ),
      Achievement(
        id: '3',
        title: '300km達成',
        description: '累計300kmを歩いた！',
        iconEmoji: '🥇',
        unlockedDate: now.subtract(const Duration(days: 5)),
        isUnlocked: true,
        progress: 312,
        target: 300,
        category: AchievementCategory.distance,
      ),
      Achievement(
        id: '4',
        title: '500km達成',
        description: '累計500kmを歩こう！',
        iconEmoji: '⭐',
        isUnlocked: false,
        progress: 312,
        target: 500,
        category: AchievementCategory.distance,
      ),
      Achievement(
        id: '5',
        title: '多様性マスター',
        description: '多様性スコア200を達成しよう',
        iconEmoji: '🌈',
        isUnlocked: false,
        progress: 150,
        target: 200,
        category: AchievementCategory.diversity,
      ),
      Achievement(
        id: '6',
        title: '7日連続',
        description: '7日間連続で散歩した！',
        iconEmoji: '🔥',
        unlockedDate: now.subtract(const Duration(days: 30)),
        isUnlocked: true,
        progress: 7,
        target: 7,
        category: AchievementCategory.streak,
      ),
      Achievement(
        id: '7',
        title: '30日連続',
        description: '30日間連続で散歩しよう',
        iconEmoji: '💪',
        isUnlocked: false,
        progress: 12,
        target: 30,
        category: AchievementCategory.streak,
      ),
      Achievement(
        id: '8',
        title: '探検家',
        description: '新しい場所を10か所発見した！',
        iconEmoji: '🗺️',
        unlockedDate: now.subtract(const Duration(days: 45)),
        isUnlocked: true,
        progress: 10,
        target: 10,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '9',
        title: 'トレジャーハンター',
        description: 'レアグッズを5個見つけよう',
        iconEmoji: '💎',
        isUnlocked: false,
        progress: 4,
        target: 5,
        category: AchievementCategory.special,
      ),
      Achievement(
        id: '10',
        title: '東京を制覇',
        description: '東京都で初めて散歩した！',
        iconEmoji: '🗼',
        unlockedDate: now.subtract(const Duration(days: 180)),
        isUnlocked: true,
        progress: 1,
        target: 1,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '11',
        title: '神奈川探訪',
        description: '神奈川県で初めて散歩した！',
        iconEmoji: '⛵',
        unlockedDate: now.subtract(const Duration(days: 90)),
        isUnlocked: true,
        progress: 1,
        target: 1,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '12',
        title: '千葉アドベンチャー',
        description: '千葉県で初めて散歩した！',
        iconEmoji: '🏖️',
        unlockedDate: now.subtract(const Duration(days: 120)),
        isUnlocked: true,
        progress: 1,
        target: 1,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '13',
        title: '3県トラベラー',
        description: '3つの都道府県で散歩した！',
        iconEmoji: '🚗',
        unlockedDate: now.subtract(const Duration(days: 90)),
        isUnlocked: true,
        progress: 3,
        target: 3,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '14',
        title: '5県マスター',
        description: '5つの都道府県で散歩しよう',
        iconEmoji: '✈️',
        isUnlocked: false,
        progress: 3,
        target: 5,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '15',
        title: '全国制覇への道',
        description: '10都道府県で散歩しよう',
        iconEmoji: '🗾',
        isUnlocked: false,
        progress: 3,
        target: 10,
        category: AchievementCategory.exploration,
      ),
      Achievement(
        id: '16',
        title: '温泉旅行',
        description: '温泉地で散歩した！',
        iconEmoji: '♨️',
        unlockedDate: now.subtract(const Duration(days: 150)),
        isUnlocked: true,
        progress: 1,
        target: 1,
        category: AchievementCategory.special,
      ),
    ];
  }

  List<Territory> getTerritories() {
    final now = DateTime.now();
    return [
      Territory(
        areaName: '代々木公園エリア',
        zones: [
          TerritoryZone(
            latitude: 35.6762,
            longitude: 139.6503,
            radiusMeters: 50,
            markingCount: 15,
            lastMarked: now.subtract(const Duration(hours: 2)),
            isActive: true,
          ),
          TerritoryZone(
            latitude: 35.6770,
            longitude: 139.6510,
            radiusMeters: 40,
            markingCount: 8,
            lastMarked: now.subtract(const Duration(days: 1)),
            isActive: true,
          ),
        ],
        coveragePercentage: 65.0,
        totalMarkings: 23,
        lastVisited: now.subtract(const Duration(hours: 2)),
      ),
      Territory(
        areaName: '明治神宮エリア',
        zones: [
          TerritoryZone(
            latitude: 35.6764,
            longitude: 139.6993,
            radiusMeters: 60,
            markingCount: 12,
            lastMarked: now.subtract(const Duration(days: 3)),
            isActive: false, // 雨で消えた
          ),
        ],
        coveragePercentage: 30.0,
        totalMarkings: 12,
        lastVisited: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // アクセサリー
  List<Accessory> getAccessories() {
    return [
      Accessory(
        id: '1',
        name: 'ピンクリボン',
        emoji: '🎀',
        rarity: 'common',
        isUnlocked: true,
        unlockedFrom: '初回ボーナス',
      ),
      Accessory(
        id: '2',
        name: 'シルクハット',
        emoji: '🎩',
        rarity: 'rare',
        isUnlocked: true,
        unlockedFrom: '代々木公園で発見',
      ),
      Accessory(
        id: '3',
        name: 'ゴールデンクラウン',
        emoji: '👑',
        rarity: 'epic',
        isUnlocked: true,
        unlockedFrom: '100km達成報酬',
      ),
      Accessory(
        id: '4',
        name: '骨のおもちゃ',
        emoji: '🦴',
        rarity: 'common',
        isUnlocked: true,
        unlockedFrom: '明治神宮で発見',
      ),
      Accessory(
        id: '5',
        name: 'サッカーボール',
        emoji: '⚽',
        rarity: 'rare',
        isUnlocked: true,
        unlockedFrom: '多様性スコア100達成',
      ),
      Accessory(
        id: '6',
        name: 'ダイヤモンドカラー',
        emoji: '💎',
        rarity: 'legendary',
        isUnlocked: false,
        unlockedFrom: null,
      ),
      Accessory(
        id: '7',
        name: 'メガネ',
        emoji: '🤓',
        rarity: 'rare',
        isUnlocked: false,
        unlockedFrom: null,
      ),
    ];
  }

  // 今週の統計
  Map<String, dynamic> getWeeklyStats() {
    return {
      'totalDistance': 12.5,
      'totalWalks': 5,
      'totalTime': 222,
      'avgPace': 17.8,
      'diversityScore': 45,
      'caloriesBurned': 580,
      'weeklyGoalProgress': 0.83, // 83%
    };
  }

  // 今月の統計
  Map<String, dynamic> getMonthlyStats() {
    return {
      'totalDistance': 48.7,
      'totalWalks': 21,
      'totalTime': 892,
      'avgPace': 18.3,
      'diversityScore': 150,
      'caloriesBurned': 2340,
      'newPlacesExplored': 8,
      'itemsFound': 4,
    };
  }

  List<HealthData> getHealthHistory() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return HealthData(
        date: date,
        walkingStability: (85 + (index % 3) * 5 - (index == 5 ? 10 : 0)).toInt(),
        waterIntake: (4 + (index % 3) - (index == 5 ? 2 : 0)).toInt(),
        scratchingCount: (2 + (index % 2) + (index == 5 ? 3 : 0)).toInt(),
        shakingCount: (index == 5 ? 8 : 1 + (index % 2)).toInt(),
        panting: (30 + (index % 4) * 10).toInt(),
        energyLevel: (80 + (index % 3) * 5).toDouble(),
      );
    });
  }

  List<HealthAlert> getHealthAlerts() {
    final now = DateTime.now();
    return [
      HealthAlert(
        title: '水分補給のリマインド',
        message: '今日はまだ水を2回しか飲んでいません。散歩後は水分補給をしましょう。',
        iconEmoji: '💧',
        level: HealthAlertLevel.warning,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      HealthAlert(
        title: '体を掻く回数が増加',
        message: '昨日は通常より多く体を掻いていました。皮膚の状態を確認してください。',
        iconEmoji: '🩺',
        level: HealthAlertLevel.info,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
    ];
  }

  // 今日の健康サマリー
  Map<String, dynamic> getTodayHealthSummary() {
    return {
      'overallScore': 85,
      'waterIntake': 3,
      'targetWaterIntake': 6,
      'scratchingCount': 2,
      'shakingCount': 1,
      'walkingStability': 88,
      'energyLevel': 85,
    };
  }
_generateMockRoute(
    double startLat,
    double startLng,
    int points,
  ) {
    final route = <LocationPoint>[];
    final now = DateTime.now();
    double lat = startLat;
    double lng = startLng;

    for (int i = 0; i < points; i++) {
      route.add(LocationPoint(
        latitude: lat,
        longitude: lng,
        timestamp: now.subtract(Duration(minutes: points - i)),
      ));
      lat += (0.0001 * (i % 3 - 1));
      lng += (0.0001 * ((i + 1) % 3 - 1));
    }

    return route;
  }
}
