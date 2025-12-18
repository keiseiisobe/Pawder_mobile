import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'walk_view_model.dart';

class WalkScreen extends StatelessWidget {
  const WalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalkViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('散歩の記録', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('週'),
                  selected: vm.period == WalkPeriod.week,
                  onSelected: (_) => vm.changePeriod(WalkPeriod.week),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('月'),
                  selected: vm.period == WalkPeriod.month,
                  onSelected: (_) => vm.changePeriod(WalkPeriod.month),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= vm.points.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  vm.points[index].dayLabel,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: const Color(0xFFFF7043),
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          spots: [
                            for (int i = 0; i < vm.points.length; i++)
                              FlSpot(i.toDouble(), vm.points[i].value),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


