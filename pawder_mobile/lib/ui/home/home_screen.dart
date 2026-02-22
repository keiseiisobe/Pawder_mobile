import 'package:flutter/material.dart';
import '../../models/dog_profile.dart';
import '../../services/mock_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mockData = MockDataService();
  late DogProfile _dogProfile;
  late Map<String, dynamic> _weeklyStats;

  @override
  void initState() {
    super.initState();
    _dogProfile = _mockData.getDogProfile();
    _weeklyStats = _mockData.getWeeklyStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'おかえり、',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      _dogProfile.name,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
            ),

            // 犬のアバター
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D084).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          _dogProfile.avatarEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: Text(
                            _dogProfile.currentAccessory,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'レベル ${_dogProfile.level}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '多様性スコア: ${_dogProfile.diversityScore}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF00D084),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // 今週の統計
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今週の散歩',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 統計カード
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate([
                  _buildStatCard(
                    context,
                    '🏃',
                    '${_weeklyStats['totalDistance']}',
                    'km',
                    '距離',
                  ),
                  _buildStatCard(
                    context,
                    '⏱️',
                    '${_weeklyStats['totalTime']}',
                    '分',
                    '時間',
                  ),
                  _buildStatCard(
                    context,
                    '🐾',
                    '${_weeklyStats['totalWalks']}',
                    '回',
                    '散歩',
                  ),
                  _buildStatCard(
                    context,
                    '🔥',
                    '${_weeklyStats['caloriesBurned']}',
                    'kcal',
                    'カロリー',
                  ),
                ]),
              ),
            ),

            // 週間目標
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D084), Color(0xFF00A870)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '週間目標',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _weeklyStats['weeklyGoalProgress'],
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_weeklyStats['weeklyGoalProgress'] * 100).toInt()}% 達成！',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'あと少しで今週の目標達成です 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 散歩を始めるボタン
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      _showWalkStartDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '散歩を始める',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String emoji,
    String value,
    String unit,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWalkStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('散歩を始める'),
        content: const Text('散歩のトラッキングを開始しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('散歩を開始しました！🐾'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('開始'),
          ),
        ],
      ),
    );
  }
}
