import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DogProfile {
  DogProfile({
    required this.name,
    required this.ageYears,
    required this.avatarColor,
  });

  final String name;
  final int ageYears;
  final Color avatarColor;
}

class TodayActivity {
  TodayActivity({
    required this.distanceKm,
    required this.durationMinutes,
    required this.calories,
    required this.routePolyline,
  });

  final double distanceKm;
  final int durationMinutes;
  final int calories;
  final List<LatLng> routePolyline;
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    _loadMockData();
  }

  late DogProfile dogProfile;
  late TodayActivity todayActivity;

  void _loadMockData() {
    dogProfile = DogProfile(
      name: 'ロック',
      ageYears: 4,
      avatarColor: const Color(0xFF1C1F2B),
    );

    todayActivity = TodayActivity(
      distanceKm: 4.2,
      durationMinutes: 55,
      calories: 310,
      routePolyline: const [
        LatLng(35.681236, 139.767125),
        LatLng(35.682, 139.77),
        LatLng(35.683, 139.772),
        LatLng(35.684, 139.769),
      ],
    );
  }
}


