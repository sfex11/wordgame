import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/level_config.dart';
import 'character_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          final state = provider.gameState;
          final characterInfo = CharacterScreen.characterInfo[state.selectedCharacter];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 프로필 카드
                _buildProfileCard(state, characterInfo),

                const SizedBox(height: 24),

                // 통계
                _buildStatsSection(state),

                const SizedBox(height: 24),

                // 주간 배지
                _buildBadgeSection(state),

                const SizedBox(height: 24),

                // 수집품 요약
                _buildCollectionSummary(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(dynamic state, Map<String, dynamic>? characterInfo) {
    final color = characterInfo?['color'] as Color? ?? const Color(0xFF4CAF50);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
        ),
        child: Column(
          children: [
            // 캐릭터 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                characterInfo?['icon'] as IconData? ?? Icons.person,
                size: 50,
                color: color,
              ),
            ),

            const SizedBox(height: 16),

            // 캐릭터 이름
            Text(
              characterInfo?['name'] as String? ?? '초보자',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // 레벨 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '레벨 ${state.maxUnlockedLevel}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 코인
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 28),
                const SizedBox(width: 8),
                Text(
                  '${state.totalCoins}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(dynamic state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '게임 통계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.emoji_events,
                    '총 점수',
                    '${state.totalScore}',
                    const Color(0xFFFFD700),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.check_circle,
                    '클리어',
                    '${state.completedLevels.length}/50',
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.book,
                    '수집 단어',
                    '${state.collectedWords.length}',
                    const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.local_fire_department,
                    '연속 출석',
                    '${state.dailyStreak}일',
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(dynamic state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주간 배지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weeklyBadgeGoals.map((badge) {
                final achieved = state.dailyStreak >= badge['days'];
                return _buildBadgeItem(
                  '${badge['days']}일',
                  badge['reward'] as int,
                  achieved,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String label, int reward, bool achieved) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFFFFD700) : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: achieved
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            achieved ? Icons.military_tech : Icons.military_tech_outlined,
            color: achieved ? Colors.white : Colors.grey,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achieved ? Colors.black87 : Colors.grey,
          ),
        ),
        Text(
          '+$reward',
          style: TextStyle(
            fontSize: 12,
            color: achieved ? const Color(0xFFFFD700) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionSummary(BuildContext context, dynamic state) {
    int totalItems = 0;
    int ownedItems = state.unlockedItems.length;

    for (var category in collectibleItems.values) {
      totalItems += category.length;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '수집품',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$ownedItems / $totalItems',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalItems > 0 ? ownedItems / totalItems : 0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryProgress(
                  '명품',
                  Icons.diamond,
                  state.unlockedItems,
                  collectibleItems['luxury'] ?? [],
                ),
                _buildCategoryProgress(
                  '자동차',
                  Icons.directions_car,
                  state.unlockedItems,
                  collectibleItems['car'] ?? [],
                ),
                _buildCategoryProgress(
                  '가전',
                  Icons.tv,
                  state.unlockedItems,
                  collectibleItems['electronics'] ?? [],
                ),
                _buildCategoryProgress(
                  '부동산',
                  Icons.home,
                  state.unlockedItems,
                  collectibleItems['realestate'] ?? [],
                ),
                _buildCategoryProgress(
                  '여행',
                  Icons.flight,
                  state.unlockedItems,
                  collectibleItems['travel'] ?? [],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(
    String label,
    IconData icon,
    List<String> owned,
    List<Map<String, dynamic>> items,
  ) {
    int ownedCount = 0;
    for (var item in items) {
      if (owned.contains(item['id'])) ownedCount++;
    }

    return Column(
      children: [
        Icon(icon, color: const Color(0xFF9C27B0)),
        const SizedBox(height: 4),
        Text(
          '$ownedCount/${items.length}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
