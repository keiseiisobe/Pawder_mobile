import 'package:flutter/material.dart';
import '../../models/walk_activity.dart';
import '../../models/achievement.dart';
import '../../services/mock_data_service.dart';
import 'walk_detail_screen.dart';
import '../health/health_screen.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _mockData = MockDataService();
  late List<WalkActivity> _walkHistory;
  late List<Achievement> _achievements;
  late Map<String, dynamic> _monthlyStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _walkHistory = _mockData.getWalkHistory();
    _achievements = _mockData.getAchievements();
    _monthlyStats = _mockData.getMonthlyStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'アクティビティ',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),

            // タブバー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  labelPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '履歴'),
                    Tab(text: '統計'),
                    Tab(text: 'バッジ'),
                  ],
                ),
              ),
            ),

            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildStatsTab(),
                  _buildAchievementsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _walkHistory.length,
      itemBuilder: (context, index) {
        final walk = _walkHistory[index];
        return _buildWalkCard(walk);
      },
    );
  }

  Widget _buildWalkCard(WalkActivity walk) {
    final dateFormat = DateFormat('M月d日');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalkDetailScreen(walk: walk),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      walk.moodEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(walk.date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            timeFormat.format(walk.date),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildWalkStat('距離', '${walk.distanceKm} km'),
                    const SizedBox(width: 24),
                    _buildWalkStat('時間', '${walk.durationMinutes} 分'),
                    const SizedBox(width: 24),
                    _buildWalkStat('ペース', '${walk.paceMinPerKm.toStringAsFixed(1)} min/km'),
                  ],
                ),
                if (walk.sniffingPoints.any((p) => p.foundItem != null)) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D084).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          'レアアイテムを発見！',
                          style: TextStyle(
                            color: const Color(0xFF00D084),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalkStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            '今月の統計',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF333333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildStatRow('総距離', '${_monthlyStats['totalDistance']} km', '🏃'),
                const Divider(color: Colors.white24, height: 32),
                _buildStatRow('散歩回数', '${_monthlyStats['totalWalks']} 回', '🐾'),
                const Divider(color: Colors.white24, height: 32),
                _buildStatRow('総時間', '${_monthlyStats['totalTime']} 分', '⏱️'),
                const Divider(color: Colors.white24, height: 32),
                _buildStatRow('平均ペース', '${_monthlyStats['avgPace']} min/km', '📊'),
              ],
            ),
          ),
          SizedBox(height: 20),
          // 健康管理カード
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D084), Color(0xFF00A870)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '🩺',
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '健康管理',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ペットの健康状態を確認',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00D084),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '🌈',
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '多様性スコア',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${_monthlyStats['diversityScore']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'さまざまな場所で散歩をして、多様性を高めよう！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSmallStatCard(
                  '新しい場所',
                  '${_monthlyStats['newPlacesExplored']}',
                  '🗺️',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallStatCard(
                  'レアアイテム',
                  '${_monthlyStats['itemsFound']}',
                  '✨',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String emoji) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final unlocked = _achievements.where((a) => a.isUnlocked).toList();
    final locked = _achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlocked.isNotEmpty) ...[
            Text(
              '達成済み (${unlocked.length})',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ...unlocked.map((achievement) => _buildAchievementCard(achievement)),
          ],
          const SizedBox(height: 24),
          if (locked.isNotEmpty) ...[
            Text(
              '未達成 (${locked.length})',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ...locked.map((achievement) => _buildAchievementCard(achievement)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: achievement.isUnlocked
            ? Border.all(color: const Color(0xFF00D084), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? const Color(0xFF00D084).withOpacity(0.1)
                  : Colors.black12,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Opacity(
                opacity: achievement.isUnlocked ? 1.0 : 0.4,
                child: Text(
                  achievement.iconEmoji,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked ? Colors.black : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: achievement.isUnlocked ? Colors.black54 : Colors.black38,
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progressPercentage / 100,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D084)),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}/${achievement.target}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                    ),
                  ),
                ],
                if (achievement.isUnlocked && achievement.unlockedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('yyyy年M月d日').format(achievement.unlockedDate!)}達成',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF00D084),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
