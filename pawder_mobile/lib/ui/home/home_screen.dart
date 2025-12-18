import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ユーザー名 Lv. 42', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildLevelProgress(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _DogProfileCard(profile: vm.dogProfile)),
          SliverToBoxAdapter(child: _TodayActivityCard(activity: vm.todayActivity)),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 10,
            color: Colors.grey.shade300,
          ),
          FractionallySizedBox(
            widthFactor: 0.42,
            child: Container(
              height: 10,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A00), Color(0xFFFF3D00)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DogProfileCard extends StatelessWidget {
  const _DogProfileCard({required this.profile});

  final DogProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'マイペット',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '名前: ${profile.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '年齢: ${profile.ageYears}歳',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '冒険回数: 543回\n総距離: 2,432km',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: const DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/dog_emoji.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayActivityCard extends StatelessWidget {
  const _TodayActivityCard({required this.activity});

  final TodayActivity activity;

  @override
  Widget build(BuildContext context) {
    final center = activity.routePolyline.isNotEmpty
        ? activity.routePolyline.first
        : const LatLng(35.681236, 139.767125);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '本日の運動',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'TiB',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.pawder_mobile',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: activity.routePolyline,
                          color: const Color(0xFFFF7043),
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric(
                  label: '距離',
                  value: '${activity.distanceKm.toStringAsFixed(1)} km',
                ),
                _metric(
                  label: '時間',
                  value: '${activity.durationMinutes} 分',
                ),
                _metric(
                  label: '消費カロリー',
                  value: '${activity.calories} kcal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


