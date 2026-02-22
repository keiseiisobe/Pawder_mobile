class HealthData {
  final DateTime date;
  final int walkingStability;
  final int waterIntake;
  final int scratchingCount;
  final int shakingCount;
  final int panting;
  final double energyLevel;

  HealthData({
    required this.date,
    required this.walkingStability,
    required this.waterIntake,
    required this.scratchingCount,
    required this.shakingCount,
    required this.panting,
    required this.energyLevel,
  });
}

class HealthAlert {
  final String title;
  final String message;
  final String iconEmoji;
  final HealthAlertLevel level;
  final DateTime timestamp;

  HealthAlert({
    required this.title,
    required this.message,
    required this.iconEmoji,
    required this.level,
    required this.timestamp,
  });
}

enum HealthAlertLevel {
  info,
  warning,
  critical,
}
