class DogProfile {
  final String name;
  final String breed;
  final int ageYears;
  final double weightKg;
  final String avatarEmoji;
  final List<String> unlockedAccessories;
  final String currentAccessory;
  final int level;
  final int totalWalks;
  final double totalDistanceKm;
  final int diversityScore;

  DogProfile({
    required this.name,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.avatarEmoji,
    required this.unlockedAccessories,
    required this.currentAccessory,
    required this.level,
    required this.totalWalks,
    required this.totalDistanceKm,
    required this.diversityScore,
  });
}

class Accessory {
  final String id;
  final String name;
  final String emoji;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final bool isUnlocked;
  final String? unlockedFrom; // どこで手に入れたか

  Accessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.isUnlocked,
    this.unlockedFrom,
  });
}
