import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'home_view_model.dart';
import '../widgets/dog_behavior_animation_widget.dart';
import '../../models/dog_status_model.dart';
import '../../services/bluetooth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
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
              profile: homeVm.dogProfile,
              dogStatus: homeVm.currentDogStatus,
              connectionModel: homeVm.connectionModel,
              onScanPressed: homeVm.scanForDevices,
              onConnectPressed: homeVm.connectToDevice,
              onDisconnectPressed: homeVm.disconnectDevice,
              bluetoothService: homeVm.bluetoothService,
            ),
          ),
          SliverToBoxAdapter(child: _TodayStatsCard(stats: homeVm.todayStats)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('最近の散歩', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: _RecentWalksCard(
              walks: homeVm.recentWalks,
              selectedView: homeVm.selectedWalkView,
              onViewSelected: homeVm.selectWalkView,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('バッジ', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(child: _BadgesGrid(badges: homeVm.badges)),
        ],
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
    required this.bluetoothService,
  });

  final DogProfile profile;
  final DogStatusModel? dogStatus;
  final DeviceConnectionModel connectionModel;
  final VoidCallback onScanPressed;
  final Function(String) onConnectPressed;
  final VoidCallback onDisconnectPressed;
  final BluetoothService bluetoothService;

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
            // Pet information and connection status row
            Row(
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
                      const SizedBox(height: 4),
                      // Connection status
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
                      // Battery indicator
                      if (connectionModel.isConnected && dogStatus?.batteryLevel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: BatteryIndicatorWidget(
                            batteryLevel: dogStatus!.batteryLevel,
                            width: 50,
                            height: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Dog behavior animation or profile picture
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: dogStatus != null
                      ? DogBehaviorAnimationWidget(
                          behavior: dogStatus!.behavior,
                          size: 60,
                        )
                      : const Icon(
                          Icons.pets,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Behavior status text
            if (dogStatus != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                if (!connectionModel.isConnected) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onScanPressed,
                      icon: const Icon(Icons.search, size: 16),
                      label: Text(
                        bluetoothService.isScanning ? 'スキャン中...' : 'デバイス検索',
                        style: const TextStyle(fontSize: 12),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: bluetoothService.availableDevices.isNotEmpty
                          ? () => _showDeviceSelectionDialog(context)
                          : null,
                      icon: const Icon(Icons.bluetooth, size: 16),
                      label: const Text(
                        '接続',
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
                ] else
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
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('デバイスを選択'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: bluetoothService.availableDevices.length,
            itemBuilder: (context, index) {
              final device = bluetoothService.availableDevices[index];
              return ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown Device'),
                subtitle: Text(device.remoteId.str),
                onTap: () {
                  Navigator.of(context).pop();
                  onConnectPressed(device.remoteId.str);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}

class _TodayStatsCard extends StatelessWidget {
  const _TodayStatsCard({required this.stats});

  final TodayStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日のアクティビティ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '距離',
                    value: '${stats.distanceKm.toStringAsFixed(1)} km',
                    accent: const LinearGradient(
                      colors: [Color(0xFF4C70FF), Color(0xFF7FB5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _StatCard(
                        title: 'ペース',
                        value: _formatPace(stats.avgPacePerKm),
                        accent: const LinearGradient(
                          colors: [Color(0xFFFF8A3D), Color(0xFFFF5F6D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        title: '時間',
                        value: _formatDuration(stats.durationMinutes),
                        accent: const LinearGradient(
                          colors: [Color(0xFF34D399), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPace(Duration pace) {
    final m = pace.inMinutes;
    final s = pace.inSeconds % 60;
    return '$m\'${s.toString().padLeft(2, '0')}"/km';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}分';
    return '${h}時間 ${m}分';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
    this.compact = false,
  });

  final String title;
  final String value;
  final Gradient accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 78 : 160,
      decoration: BoxDecoration(
        gradient: accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: compact
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 26,
              fontWeight: FontWeight.bold,
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _BadgeCard(badge: badge);
        },
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
  final ValueChanged<WalkViewType> onViewSelected;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return const SizedBox.shrink();
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
                                    Icons.pets,
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
  const _WalkViewTabs({required this.selectedView, required this.onSelect});

  final WalkViewType selectedView;
  final ValueChanged<WalkViewType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab('ルート', WalkViewType.route),
          _buildTab('匂い', WalkViewType.smell),
          _buildTab('遊び', WalkViewType.play),
        ],
      ),
    );
  }

  Widget _buildTab(String label, WalkViewType type) {
    final isSelected = selectedView == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final AchievementBadge badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: badge.isUnlocked
          ? () {
              HapticFeedback.mediumImpact();
              _showBadgeSuccessDialog(context, badge);
            }
          : null,
      child: Card(
        color: badge.isUnlocked ? Colors.white : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                badge.icon,
                size: 32,
                color: badge.isUnlocked
                    ? const Color(0xFFFF8A3D)
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeSuccessDialog(BuildContext context, AchievementBadge badge) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'バッジ達成ダイアログ',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _BadgeSuccessDialog(badge: badge);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _BadgeSuccessDialog extends StatefulWidget {
  const _BadgeSuccessDialog({required this.badge});

  final AchievementBadge badge;

  @override
  State<_BadgeSuccessDialog> createState() => _BadgeSuccessDialogState();
}

class _BadgeSuccessDialogState extends State<_BadgeSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // 振動を2回実行（Duolingo風）
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
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A3D), Color(0xFFFF5F6D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8A3D).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.badge.icon,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _opacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            '${widget.badge.name}達成！',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.badge.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
