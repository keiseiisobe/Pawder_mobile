class Territory {
  final String areaName;
  final List<TerritoryZone> zones;
  final double coveragePercentage;
  final int totalMarkings;
  final DateTime lastVisited;

  Territory({
    required this.areaName,
    required this.zones,
    required this.coveragePercentage,
    required this.totalMarkings,
    required this.lastVisited,
  });
}

class TerritoryZone {
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final int markingCount;
  final DateTime lastMarked;
  final bool isActive; // 雨で消えたりしてないか

  TerritoryZone({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.markingCount,
    required this.lastMarked,
    required this.isActive,
  });
}
