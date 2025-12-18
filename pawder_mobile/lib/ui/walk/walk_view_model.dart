import 'package:flutter/material.dart';

class ActivityPoint {
  ActivityPoint(this.dayLabel, this.value);

  final String dayLabel;
  final double value;
}

enum WalkPeriod { week, month }

class WalkViewModel extends ChangeNotifier {
  WalkPeriod _period = WalkPeriod.week;

  WalkPeriod get period => _period;

  List<ActivityPoint> get points =>
      _period == WalkPeriod.week ? _weekly : _monthly;

  final List<ActivityPoint> _weekly = [
    ActivityPoint('月', 3.2),
    ActivityPoint('火', 4.1),
    ActivityPoint('水', 2.4),
    ActivityPoint('木', 4.8),
    ActivityPoint('金', 3.9),
    ActivityPoint('土', 5.2),
    ActivityPoint('日', 4.6),
  ];

  final List<ActivityPoint> _monthly = List.generate(
    4,
    (index) => ActivityPoint('週${index + 1}', 20.0 + index * 4),
  );

  void changePeriod(WalkPeriod period) {
    if (_period == period) return;
    _period = period;
    notifyListeners();
  }
}


