import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../widgets/dog_behavior_animation_widget.dart';
import '../../models/dog_status_model.dart';
import '../../providers/bluetooth_repository_provider.dart';

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

class TodayStats {
  TodayStats({
    required this.distanceKm,
    required this.durationMinutes,
    required this.avgPacePerKm,
    required this.calories,
    required this.routePolyline,
  });

  final double distanceKm;
  final int durationMinutes;
  final Duration avgPacePerKm;
  final int calories;
  final List<LatLng> routePolyline;
}

class AchievementBadge {
  AchievementBadge({
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });

  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
}

enum WalkViewType { route, smell, play }

class RecentWalk {
  RecentWalk({
    required this.date,
    required this.routePolyline,
    required this.smellPoints,
    required this.playPoints,
  });

  final DateTime date;
  final List<LatLng> routePolyline;
  final List<LatLng> smellPoints;
  final List<LatLng> playPoints;
}

class DeviceConnectionModel {
  DeviceConnectionModel({
    this.deviceId,
    this.deviceName,
    required this.isConnected,
    this.connectionStatus,
  });

  final String? deviceId;
  final String? deviceName;
  final bool isConnected;
  final String? connectionStatus;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WalkViewType _selectedWalkView = WalkViewType.route;
  late DogProfile dogProfile;
  late TodayStats todayStats;
  late List<AchievementBadge> badges;
  late List<RecentWalk> recentWalks;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBluetooth();
    });
  }

  Future<void> _initializeBluetooth() async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    await bluetoothProvider.initializeBluetooth();
  }

  Future<void> _refresh() async {
    // リフレッシュ処理
    await Future.delayed(const Duration(seconds: 1));
  }

  void _selectWalkView(WalkViewType type) {
    if (_selectedWalkView == type) return;
    setState(() {
      _selectedWalkView = type;
    });
  }

  Future<void> _scanForDevices() async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    await bluetoothProvider.startScanning();
  }

  Future<void> _connectToDevice(String deviceId) async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    final devices = bluetoothProvider.availableDevices;
    final device = devices.firstWhere(
      (d) => d.remoteId.str == deviceId,
      orElse: () => throw Exception('デバイスが見つかりません'),
    );
    
    await bluetoothProvider.connectToDevice(device);
  }

  Future<void> _disconnectDevice() async {
    final bluetoothProvider = context.read<BluetoothRepositoryProvider>();
    await bluetoothProvider.disconnect();
  }

  void _loadMockData() {
    dogProfile = DogProfile(
      name: 'レッカー',
      ageYears: 4,
      avatarColor: const Color(0xFF1C1F2B),
    );

    todayStats = TodayStats(
      distanceKm: 4.2,
      durationMinutes: 55,
      avgPacePerKm: const Duration(minutes: 5, seconds: 12),
      calories: 310,
      routePolyline: const [
        LatLng(35.681236, 139.767125),
        LatLng(35.682, 139.77),
        LatLng(35.683, 139.772),
        LatLng(35.684, 139.769),
      ],
    );

    badges = [
      AchievementBadge(
        name: '初回散歩',
        description: '初めての散歩を完了しました',
        icon: Icons.directions_walk,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AchievementBadge(
        name: 'アクティブ',
        description: '7日連続で散歩しました',
        icon: Icons.local_fire_department,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AchievementBadge(
        name: '距離の達人',
        description: '10km歩きました',
        icon: Icons.emoji_events,
        isUnlocked: false,
      ),
    ];

    recentWalks = [
      RecentWalk(
        date: DateTime.now().subtract(const Duration(days: 1)),
        routePolyline: const [
          LatLng(35.681236, 139.767125),
          LatLng(35.682, 139.77),
          LatLng(35.683, 139.772),
          LatLng(35.684, 139.769),
        ],
        smellPoints: const [
          LatLng(35.682, 139.77),
          LatLng(35.683, 139.772),
        ],
        playPoints: const [
          LatLng(35.684, 139.769),
        ],
      ),
      RecentWalk(
        date: DateTime.now().subtract(const Duration(days: 2)),
        routePolyline: const [
          LatLng(35.680, 139.765),
          LatLng(35.681, 139.768),
          LatLng(35.682, 139.771),
        ],
        smellPoints: const [
          LatLng(35.681, 139.768),
        ],
        playPoints: const [
          LatLng(35.682, 139.771),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothRepositoryProvider>();
    final theme = Theme.of(context);

    // BluetoothProviderからの状態を使用してDeviceConnectionModelを作成
    final connectionModel = DeviceConnectionModel(
      deviceId: bluetoothProvider.deviceId,
      deviceName: bluetoothProvider.deviceName,
      isConnected: bluetoothProvider.isConnected,
      connectionStatus: bluetoothProvider.connectionStatus,
    );

    // DogStatusDataからDogStatusModelを作成
    DogStatusModel? dogStatusModel;
    if (bluetoothProvider.currentDogStatus != null) {
      debugPrint('Current Dog Behavior: ${bluetoothProvider.currentDogStatus!.behavior}');
      dogStatusModel = DogStatusModel(
        behavior: bluetoothProvider.currentDogStatus!.behavior,
        batteryLevel: bluetoothProvider.currentDogStatus!.batteryPercentage,
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1C1F2B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ユーザー名 Lv. 42',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildLevelProgress(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _DogProfileCard(
                profile: dogProfile,
                dogStatus: dogStatusModel,
                connectionModel: connectionModel,
                onScanPressed: _scanForDevices,
                onConnectPressed: _connectToDevice,
                onDisconnectPressed: _disconnectDevice,
                bluetoothProvider: bluetoothProvider,
              ),
            ),
            SliverToBoxAdapter(child: _TodayStatsCard(stats: todayStats)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('最近の散歩', style: theme.textTheme.titleMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: _RecentWalksCard(
                walks: recentWalks,
                selectedView: _selectedWalkView,
                onViewSelected: _selectWalkView,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('バッジ', style: theme.textTheme.titleMedium),
              ),
            ),
            SliverToBoxAdapter(child: _BadgesGrid(badges: badges)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '42%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(height: 10, color: Colors.grey.shade300),
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
        ),
      ],
    );
  }
}

class _DogProfileCard extends StatelessWidget {
  const _DogProfileCard({
    required this.profile,
    this.dogStatus,
    required this.connectionModel,
    required this.onScanPressed,
    required this.onConnectPressed,
    required this.onDisconnectPressed,
    required this.bluetoothProvider,
  });

  final DogProfile profile;
  final DogStatusModel? dogStatus;
  final DeviceConnectionModel connectionModel;
  final VoidCallback onScanPressed;
  final Function(String) onConnectPressed;
  final VoidCallback onDisconnectPressed;
  final BluetoothRepositoryProvider bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A3D), Color(0xFFFF5F6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '名前: ${profile.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            connectionModel.isConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: connectionModel.isConnected
                                ? Colors.greenAccent
                                : Colors.red.shade300,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              connectionModel.isConnected
                                  ? connectionModel.deviceName ?? '接続済み'
                                  : '未接続',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (connectionModel.isConnected && dogStatus?.batteryLevel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.battery_full,
                                color: Colors.greenAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dogStatus!.batteryLevel}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Dog image and behavior animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dog image background
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/lecker.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to pet icon if image fails to load
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Behavior status overlay
                    if (dogStatus != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showBehaviorDialog(context, dogStatus!.behavior),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _getBehaviorColor(dogStatus!.behavior),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getBehaviorIcon(dogStatus!.behavior),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Current behavior display
            if (dogStatus != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dogStatus!.behavior.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 12),
            // Connection actions
            Row(
              children: [
                if (connectionModel.isConnected) ...[
                Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDisconnectPressed,
                      icon: const Icon(Icons.bluetooth_disabled, size: 16),
                      label: const Text(
                        '切断',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF5F6D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBehaviorDialog(BuildContext context, DogBehavior behavior) {
    showDialog(
      context: context,
      builder: (context) => _BehaviorDialog(behavior: behavior),
    );
  }

  Color _getBehaviorColor(DogBehavior behavior) {
    switch (behavior) {
      case DogBehavior.playing:
        return const Color(0xFF34D399); // Green
      case DogBehavior.walking:
      case DogBehavior.trotting:
        return const Color(0xFF3B82F6); // Blue
      case DogBehavior.sniffing:
        return const Color(0xFFF59E0B); // Orange
      case DogBehavior.drinking:
        return const Color(0xFF06B6D4); // Cyan
      case DogBehavior.resting:
        return const Color(0xFF8B5CF6); // Purple
      case DogBehavior.shaking:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData _getBehaviorIcon(DogBehavior behavior) {
    switch (behavior) {
      case DogBehavior.playing:
        return Icons.sports_tennis;
      case DogBehavior.walking:
        return Icons.directions_walk;
      case DogBehavior.trotting:
        return Icons.directions_run;
      case DogBehavior.sniffing:
        return Icons.search;
      case DogBehavior.drinking:
        return Icons.water_drop;
      case DogBehavior.resting:
        return Icons.bedtime;
      case DogBehavior.shaking:
        return Icons.vibration;
    }
  }
}

class _TodayStatsCard extends StatelessWidget {
  const _TodayStatsCard({required this.stats});

  final TodayStats stats;

  @override
  Widget build(BuildContext context) {
    final distanceText = stats.distanceKm.toStringAsFixed(1);
    final timeText = '${stats.durationMinutes}分';
    final paceText = '${stats.avgPacePerKm.inMinutes}:${(stats.avgPacePerKm.inSeconds % 60).toString().padLeft(2, '0')}';
    final caloriesText = '${stats.calories}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日の活動',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '距離',
                    value: distanceText,
                    unit: 'km',
                    accent: const Color(0xFF4C70FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '時間',
                    value: timeText,
                    unit: '',
                    accent: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'ペース',
                    value: paceText,
                    unit: '/km',
                    accent: const Color(0xFFFF8A3D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'カロリー',
                    value: caloriesText,
                    unit: 'cal',
                    accent: const Color(0xFFFF5F6D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.accent,
  });

  final String title;
  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.badges});

  final List<AchievementBadge> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _BadgeCard(badge: badge);
        },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final AchievementBadge badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: badge.isUnlocked ? 4 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: badge.isUnlocked
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: badge.isUnlocked ? null : Colors.grey.shade200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              size: 32,
              color: badge.isUnlocked ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked ? Colors.white : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentWalksCard extends StatelessWidget {
  const _RecentWalksCard({
    required this.walks,
    required this.selectedView,
    required this.onViewSelected,
  });

  final List<RecentWalk> walks;
  final WalkViewType selectedView;
  final Function(WalkViewType) onViewSelected;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('散歩の記録がありません'),
          ),
        ),
      );
    }

    final latestWalk = walks.first;
    final center = latestWalk.routePolyline.isNotEmpty
        ? latestWalk.routePolyline.first
        : const LatLng(35.681236, 139.767125);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WalkViewTabs(selectedView: selectedView, onSelect: onViewSelected),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                    if (selectedView == WalkViewType.route)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: latestWalk.routePolyline,
                            color: const Color(0xFFFF8A3D),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    if (selectedView == WalkViewType.smell)
                      MarkerLayer(
                        markers: latestWalk.smellPoints
                            .map(
                              (point) => Marker(
                                point: point,
                                width: 16,
                                height: 16,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4C70FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    if (selectedView == WalkViewType.play)
                      MarkerLayer(
                        markers: latestWalk.playPoints
                            .map(
                              (point) => Marker(
                                point: point,
                                width: 20,
                                height: 20,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF34D399),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.sports_tennis,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
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
}

class _WalkViewTabs extends StatelessWidget {
  const _WalkViewTabs({
    required this.selectedView,
    required this.onSelect,
  });

  final WalkViewType selectedView;
  final Function(WalkViewType) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WalkViewTab(
            label: 'ルート',
            icon: Icons.route,
            isSelected: selectedView == WalkViewType.route,
            onTap: () => onSelect(WalkViewType.route),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WalkViewTab(
            label: '匂い嗅ぎ',
            icon: Icons.location_on,
            isSelected: selectedView == WalkViewType.smell,
            onTap: () => onSelect(WalkViewType.smell),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WalkViewTab(
            label: '遊び',
            icon: Icons.sports_tennis,
            isSelected: selectedView == WalkViewType.play,
            onTap: () => onSelect(WalkViewType.play),
          ),
        ),
      ],
    );
  }
}

class _WalkViewTab extends StatelessWidget {
  const _WalkViewTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8A3D) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BehaviorDialog extends StatefulWidget {
  const _BehaviorDialog({required this.behavior});

  final DogBehavior behavior;

  @override
  State<_BehaviorDialog> createState() => _BehaviorDialogState();
}

class _BehaviorDialogState extends State<_BehaviorDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: DogBehaviorAnimationWidget(
                          behavior: widget.behavior,
                          size: 120,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  widget.behavior.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1F2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '愛犬が${widget.behavior.displayName.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}