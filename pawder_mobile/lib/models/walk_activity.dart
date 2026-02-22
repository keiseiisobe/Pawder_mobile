class WalkActivity {
  final String id;
  final DateTime date;
  final double distanceKm;
  final int durationMinutes;
  final List<LocationPoint> route;
  final List<MarkingPoint> markings;
  final List<SniffingPoint> sniffingPoints;
  final String moodEmoji;
  final int caloriesBurned;

  WalkActivity({
    required this.id,
    required this.date,
    required this.distanceKm,
    required this.durationMinutes,
    required this.route,
    required this.markings,
    required this.sniffingPoints,
    required this.moodEmoji,
    required this.caloriesBurned,
  });

  double get paceMinPerKm => distanceKm > 0 ? durationMinutes / distanceKm : 0;
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class MarkingPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String type; // 'marking', 'favorite', 'special'

  MarkingPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.type,
  });
}

class SniffingPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int durationSeconds;
  final String? foundItem; // レアグッズ

  SniffingPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.durationSeconds,
    this.foundItem,
  });
}
