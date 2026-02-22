import 'package:flutter/material.dart';
import '../../models/dog_profile.dart';
import '../../services/mock_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _mockData = MockDataService();
  late DogProfile _dogProfile;
  late List<Accessory> _accessories;
  String _selectedAccessory = '🎀';

  @override
  void initState() {
    super.initState();
    _dogProfile = _mockData.getDogProfile();
    _accessories = _mockData.getAccessories();
    _selectedAccessory = _dogProfile.currentAccessory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  '設定',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),

            // プロフィールカード
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111111), Color(0xFF333333)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          _dogProfile.avatarEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: Text(
                            _selectedAccessory,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _dogProfile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dogProfile.breed,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileStat('${_dogProfile.ageYears}歳', '年齢'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white24,
                        ),
                        _buildProfileStat('${_dogProfile.weightKg}kg', '体重'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white24,
                        ),
                        _buildProfileStat('Lv.${_dogProfile.level}', 'レベル'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 着せ替えセクション
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Text(
                      '着せ替え',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D084),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_accessories.where((a) => a.isUnlocked).length}/${_accessories.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 着せ替えグリッド
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final accessory = _accessories[index];
                    return _buildAccessoryCard(accessory);
                  },
                  childCount: _accessories.length,
                ),
              ),
            ),

            // 統計セクション
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  '通算記録',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),

            // 統計カード
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildTotalStatRow('🐾', '総散歩回数', '${_dogProfile.totalWalks}回'),
                      const Divider(height: 32),
                      _buildTotalStatRow('🏃', '総距離', '${_dogProfile.totalDistanceKm}km'),
                      const Divider(height: 32),
                      _buildTotalStatRow('🌈', '多様性スコア', '${_dogProfile.diversityScore}'),
                    ],
                  ),
                ),
              ),
            ),

            // その他の設定
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  'その他',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem('通知設定', Icons.notifications_outlined),
                      const Divider(height: 1, indent: 60),
                      _buildSettingItem('プライバシー設定', Icons.lock_outline),
                      const Divider(height: 1, indent: 60),
                      _buildSettingItem('ヘルプ', Icons.help_outline),
                      const Divider(height: 1, indent: 60),
                      _buildSettingItem('アプリについて', Icons.info_outline),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessoryCard(Accessory accessory) {
    final isSelected = _selectedAccessory == accessory.emoji;
    final isLocked = !accessory.isUnlocked;

    return GestureDetector(
      onTap: accessory.isUnlocked
          ? () {
              setState(() {
                _selectedAccessory = accessory.emoji;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${accessory.name}を装備しました！'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF00D084), width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D084).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: isLocked ? 0.3 : 1.0,
                    child: Text(
                      accessory.emoji,
                      style: const TextStyle(
                        fontSize: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      accessory.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? Colors.black38 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.black38,
                      size: 32,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getRarityColor(accessory.rarity),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRarityLabel(accessory.rarity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalStatRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$titleは開発中です'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity) {
      case 'common':
        return 'C';
      case 'rare':
        return 'R';
      case 'epic':
        return 'E';
      case 'legendary':
        return 'L';
      default:
        return '';
    }
  }
}
