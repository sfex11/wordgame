import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/level_config.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  static const Map<String, Map<String, dynamic>> characterInfo = {
    'default': {
      'name': '초보자',
      'description': '모험을 시작하는 사람',
      'icon': Icons.person,
      'color': Color(0xFF4CAF50),
    },
    'student': {
      'name': '학생',
      'description': '열심히 공부하는 학생',
      'icon': Icons.school,
      'color': Color(0xFF2196F3),
    },
    'office_worker': {
      'name': '직장인',
      'description': '성실한 회사원',
      'icon': Icons.work,
      'color': Color(0xFF607D8B),
    },
    'scientist': {
      'name': '과학자',
      'description': '지식을 탐구하는 연구자',
      'icon': Icons.science,
      'color': Color(0xFF9C27B0),
    },
    'artist': {
      'name': '예술가',
      'description': '창의적인 예술가',
      'icon': Icons.palette,
      'color': Color(0xFFE91E63),
    },
    'ceo': {
      'name': 'CEO',
      'description': '성공한 사업가',
      'icon': Icons.business_center,
      'color': Color(0xFFFF9800),
    },
    'legend': {
      'name': '레전드',
      'description': '전설적인 단어 마스터',
      'icon': Icons.stars,
      'color': Color(0xFFFFD700),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터'),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        actions: [
          Consumer<GameProvider>(
            builder: (context, provider, _) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.gameState.totalCoins}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          final currentLevel = provider.gameState.maxUnlockedLevel;
          final selectedCharacter = provider.gameState.selectedCharacter;
          final unlockedCharacters = provider.gameState.unlockedCharacters;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characterUnlockRequirements.keys.length,
            itemBuilder: (context, index) {
              final characterId = characterUnlockRequirements.keys.elementAt(index);
              final requirements = characterUnlockRequirements[characterId]!;
              final info = characterInfo[characterId]!;

              final isUnlocked = unlockedCharacters.contains(characterId);
              final isSelected = selectedCharacter == characterId;
              final canUnlock = currentLevel >= requirements['level'];
              final canAfford = provider.gameState.totalCoins >= requirements['coins'];

              return _buildCharacterCard(
                context,
                provider,
                characterId,
                info,
                requirements,
                isUnlocked,
                isSelected,
                canUnlock,
                canAfford,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    GameProvider provider,
    String characterId,
    Map<String, dynamic> info,
    Map<String, dynamic> requirements,
    bool isUnlocked,
    bool isSelected,
    bool canUnlock,
    bool canAfford,
  ) {
    final color = info['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: color, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isUnlocked) {
            provider.selectCharacter(characterId);
          } else if (canUnlock && canAfford) {
            _showUnlockDialog(context, provider, characterId, info, requirements);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 캐릭터 아이콘
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  info['icon'] as IconData,
                  size: 36,
                  color: isUnlocked ? color : Colors.grey,
                ),
              ),

              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info['name'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '선택됨',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isUnlocked)
                      _buildUnlockRequirements(requirements, canUnlock, canAfford),
                  ],
                ),
              ),

              // 상태 아이콘
              if (isUnlocked)
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? color : Colors.grey,
                  size: 28,
                )
              else if (!canUnlock)
                const Icon(Icons.lock, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockRequirements(
    Map<String, dynamic> requirements,
    bool canUnlock,
    bool canAfford,
  ) {
    return Row(
      children: [
        // 레벨 요구사항
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: canUnlock ? const Color(0xFFE8F5E9) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: canUnlock ? const Color(0xFF4CAF50) : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '레벨 ${requirements['level']}',
                style: TextStyle(
                  fontSize: 12,
                  color: canUnlock ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // 코인 요구사항
        if (requirements['coins'] > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: canAfford ? const Color(0xFFFFF8E1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 14,
                  color: canAfford ? const Color(0xFFFFD700) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${requirements['coins']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: canAfford ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showUnlockDialog(
    BuildContext context,
    GameProvider provider,
    String characterId,
    Map<String, dynamic> info,
    Map<String, dynamic> requirements,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${info['name']} 해금'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (info['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                info['icon'] as IconData,
                size: 40,
                color: info['color'] as Color,
              ),
            ),
            const SizedBox(height: 16),
            Text(info['description'] as String),
            const SizedBox(height: 16),
            if (requirements['coins'] > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('비용: '),
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
                  Text(
                    '${requirements['coins']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final success = provider.unlockCharacter(
                characterId,
                requirements['coins'] as int,
              );
              Navigator.pop(context);

              if (success) {
                provider.selectCharacter(characterId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${info['name']}을(를) 해금했습니다!'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            child: const Text('해금'),
          ),
        ],
      ),
    );
  }
}
