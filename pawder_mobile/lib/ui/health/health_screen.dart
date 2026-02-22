import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/health_data.dart';
import '../../services/mock_data_service.dart';
import 'package:intl/intl.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _mockData = MockDataService();
  late List<HealthData> _healthHistory;
  late List<HealthAlert> _alerts;
  late Map<String, dynamic> _todaySummary;

  @override
  void initState() {
    super.initState();
    _healthHistory = _mockData.getHealthHistory();
    _alerts = _mockData.getHealthAlerts();
    _todaySummary = _mockData.getTodayHealthSummary();
  }

  @override
  Widget build(BuildContext context) {
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
          '健康管理',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日の健康スコア
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D084), Color(0xFF00A870)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    '今日の健康スコア',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_todaySummary['overallScore']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '良好な状態です 😊',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // アラート
            if (_alerts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  '通知',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ..._alerts.map((alert) => _buildAlertCard(alert)),
              const SizedBox(height: 20),
            ],

            // 今日の状態
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '今日の状態',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTodayStatCard(
                      '💧',
                      '水分補給',
                      '${_todaySummary['waterIntake']}/${_todaySummary['targetWaterIntake']}回',
                      _todaySummary['waterIntake'] / _todaySummary['targetWaterIntake'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTodayStatCard(
                      '⚡',
                      'エネルギー',
                      '${_todaySummary['energyLevel']}%',
                      _todaySummary['energyLevel'] / 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSimpleStatCard(
                      '🐾',
                      '歩行安定性',
                      '${_todaySummary['walkingStability']}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSimpleStatCard(
                      '🩺',
                      '体を掻いた',
                      '${_todaySummary['scratchingCount']}回',
                    ),
                  ),
                ],
              ),
            ),

            // 週間推移グラフ
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '週間推移',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            // 歩行安定性グラフ
            _buildChartCard(
              '歩行安定性',
              '🐾',
              _healthHistory.map((d) => d.walkingStability.toDouble()).toList(),
              const Color(0xFF00D084),
            ),

            // 水分補給グラフ
            _buildChartCard(
              '水分補給回数',
              '💧',
              _healthHistory.map((d) => d.waterIntake.toDouble()).toList(),
              Colors.blue,
            ),

            // 体を掻いた回数グラフ
            _buildChartCard(
              '体を掻いた回数',
              '🩺',
              _healthHistory.map((d) => d.scratchingCount.toDouble()).toList(),
              Colors.orange,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(HealthAlert alert) {
    Color bgColor;
    Color textColor;

    switch (alert.level) {
      case HealthAlertLevel.critical:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case HealthAlertLevel.warning:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case HealthAlertLevel.info:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            alert.iconEmoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatCard(String emoji, String label, String value, double progress) {
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
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D084)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(String emoji, String label, String value) {
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
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String emoji, List<double> data, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.black12,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _healthHistory.length) {
                          final date = _healthHistory[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: data.reduce((a, b) => a > b ? a : b) * 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
