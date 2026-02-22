class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final DateTime? unlockedDate;
  final bool isUnlocked;
  final int progress;
  final int target;
  final AchievementCategory category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.unlockedDate,
    required this.isUnlocked,
    required this.progress,
    required this.target,
    required this.category,
  });

  double get progressPercentage => target > 0 ? (progress / target * 100).clamp(0, 100) : 0;
}

enum AchievementCategory {
  distance,
  diversity,
  streak,
  exploration,
  special,
}
