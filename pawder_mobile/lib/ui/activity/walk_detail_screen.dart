import 'package:flutter/material.dart';
import '../../models/walk_activity.dart';
import 'package:intl/intl.dart';

class WalkDetailScreen extends StatelessWidget {
  final WalkActivity walk;

  const WalkDetailScreen({super.key, required this.walk});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日 HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '散歩の詳細',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // マップエリア（モック）
            Container(
              height: 300,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'ルートマップ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        walk.moodEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 日時
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                dateFormat.format(walk.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 20),

            // メイン統計
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMainStat(context, '${walk.distanceKm}', 'km', '距離'),
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.white24,
                        ),
                        _buildMainStat(context, '${walk.durationMinutes}', '分', '時間'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMainStat(
                          context,
                          walk.paceMinPerKm.toStringAsFixed(1),
                          'min/km',
                          'ペース',
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.white24,
                        ),
                        _buildMainStat(context, '${walk.caloriesBurned}', 'kcal', 'カロリー'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // マーキングポイント
            if (walk.markings.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'マーキングポイント',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ...walk.markings.asMap().entries.map((entry) {
                        final i = entry.key;
                        final marking = entry.value;
                        return Column(
                          children: [
                            if (i > 0)
                              const Divider(height: 24),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getMarkingColor(marking.type).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getMarkingEmoji(marking.type),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getMarkingLabel(marking.type),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(marking.timestamp),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 匂い嗅ぎポイント
            if (walk.sniffingPoints.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '匂い嗅ぎポイント',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ...walk.sniffingPoints.asMap().entries.map((entry) {
                        final i = entry.key;
                        final sniff = entry.value;
                        return Column(
                          children: [
                            if (i > 0)
                              const Divider(height: 24),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D084).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '👃',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${sniff.durationSeconds}秒間匂いを嗅いだ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(sniff.timestamp),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (sniff.foundItem != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D084),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sniff.foundItem!,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '発見！',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainStat(
    BuildContext context,
    String value,
    String unit,
    String label,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Text(
                unit,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getMarkingEmoji(String type) {
    switch (type) {
      case 'marking':
        return '💧';
      case 'favorite':
        return '⭐';
      case 'special':
        return '✨';
      default:
        return '📍';
    }
  }

  String _getMarkingLabel(String type) {
    switch (type) {
      case 'marking':
        return 'マーキング';
      case 'favorite':
        return 'お気に入りの場所';
      case 'special':
        return '特別な場所';
      default:
        return 'マーキング';
    }
  }

  Color _getMarkingColor(String type) {
    switch (type) {
      case 'favorite':
        return Colors.amber;
      case 'special':
        return const Color(0xFF00D084);
      default:
        return Colors.blue;
    }
  }
}
