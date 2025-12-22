import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'activity_view_model.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('アクティビティ', style: theme.textTheme.headlineSmall),
          ),
          _PeriodTabs(selectedPeriod: vm.selectedPeriod, onSelect: vm.selectPeriod),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryRow(summary: vm.summary),
                const SizedBox(height: 16),
                _WeeklyChart(points: vm.currentPoints, period: vm.selectedPeriod),
                const SizedBox(height: 16),
                Text(
                  '最近のアクティビティ',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...vm.logs.map((log) => _ActivityTile(log: log)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: '今週の距離',
            value: '${summary.totalDistanceKm.toStringAsFixed(1)} km',
            accent: const LinearGradient(
              colors: [Color(0xFF4C70FF), Color(0xFF7FB5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _StatCard(
                title: '平均ペース',
                value: _formatPace(summary.avgPacePerKm),
                accent: const LinearGradient(
                  colors: [Color(0xFFFF8A3D), Color(0xFFFF5F6D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                compact: true,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: '合計時間',
                value: _formatDuration(summary.totalDurationMinutes),
                accent: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                compact: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPace(Duration pace) {
    final m = pace.inMinutes;
    final s = pace.inSeconds % 60;
    return '$m\'${s.toString().padLeft(2, '0')}"/km';
    }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m分';
    return '$h時間 $m分';
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({
    required this.selectedPeriod,
    required this.onSelect,
  });

  final ActivityPeriod selectedPeriod;
  final ValueChanged<ActivityPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab('週', ActivityPeriod.week),
          _buildTab('月', ActivityPeriod.month),
          _buildTab('年', ActivityPeriod.year),
          _buildTab('すべて', ActivityPeriod.all),
        ],
      ),
    );
  }

  Widget _buildTab(String label, ActivityPeriod period) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.points, required this.period});

  final List<ActivityPoint> points;
  final ActivityPeriod period;

  @override
  Widget build(BuildContext context) {
    final maxValue = points
        .map((e) => e.valueKm)
        .fold<double>(0, (p, c) => c > p ? c : p);
    
    // 期間に応じて適切な最大値を設定
    double maxY;
    if (maxValue == 0) {
      maxY = 10;
    } else {
      // 最大値の1.2倍を上限として、適切な単位で丸める
      double targetMax = maxValue * 1.2;
      double step;
      
      if (period == ActivityPeriod.week) {
        // 週間: 1km単位
        step = 1.0;
        maxY = (targetMax / step).ceil() * step;
        if (maxY < 4) maxY = 4;
        if (maxY > 20) maxY = 20;
      } else if (period == ActivityPeriod.month) {
        // 月間: 5km単位
        step = 5.0;
        maxY = (targetMax / step).ceil() * step;
        if (maxY < 10) maxY = 10;
      } else {
        // 年・すべて: 20km単位
        step = 20.0;
        maxY = (targetMax / step).ceil() * step;
        if (maxY < 50) maxY = 50;
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getChartTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              points[i].label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  maxY: maxY,
                  barGroups: [
                    for (int i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].valueKm,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A3D), Color(0xFFFF5F6D)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            width: 14,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChartTitle() {
    switch (period) {
      case ActivityPeriod.week:
        return '週間チャート';
      case ActivityPeriod.month:
        return '月間チャート';
      case ActivityPeriod.year:
        return '年間チャート';
      case ActivityPeriod.all:
        return 'すべてのチャート';
    }
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1C1F2B),
          child: Icon(Icons.run_circle, color: Colors.white),
        ),
        title: Text(log.title),
        subtitle: Text('${log.distanceKm.toStringAsFixed(1)} km • '
            '${_formatPace(log.pacePerKm)} • ${log.dateLabel}'),
        trailing: Text(_formatDuration(log.durationMinutes)),
      ),
    );
  }

  String _formatPace(Duration pace) {
    final m = pace.inMinutes;
    final s = pace.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}/km';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m分';
    return '$h時間$m分';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
    this.compact = false,
  });

  final String title;
  final String value;
  final Gradient accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 78 : 160,
      decoration: BoxDecoration(
        gradient: accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

