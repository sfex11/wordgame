import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/level_config.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = ['명품', '자동차', '가전', '부동산', '여행'];
  final List<String> _categoryKeys = [
    'luxury',
    'car',
    'electronics',
    'realestate',
    'travel'
  ];
  final List<IconData> _categoryIcons = [
    Icons.diamond,
    Icons.directions_car,
    Icons.tv,
    Icons.home,
    Icons.flight,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        backgroundColor: const Color(0xFF9C27B0),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: List.generate(_categories.length, (index) {
            return Tab(
              icon: Icon(_categoryIcons[index]),
              text: _categories[index],
            );
          }),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: List.generate(_categories.length, (index) {
              return _buildCategoryTab(
                provider,
                _categoryKeys[index],
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(GameProvider provider, String categoryKey) {
    final items = collectibleItems[categoryKey] ?? [];
    final currentLevel = provider.gameState.maxUnlockedLevel;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isUnlocked = provider.gameState.unlockedItems.contains(item['id']);
        final canUnlock = currentLevel >= item['unlockLevel'];
        final canAfford = provider.gameState.totalCoins >= item['price'];

        return _buildItemCard(
          provider,
          item,
          isUnlocked,
          canUnlock,
          canAfford,
        );
      },
    );
  }

  Widget _buildItemCard(
    GameProvider provider,
    Map<String, dynamic> item,
    bool isUnlocked,
    bool canUnlock,
    bool canAfford,
  ) {
    return Card(
      elevation: isUnlocked ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUnlocked
            ? const BorderSide(color: Color(0xFF4CAF50), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isUnlocked || !canUnlock || !canAfford
            ? null
            : () => _showPurchaseDialog(provider, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이템 아이콘/이미지
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFFE8F5E9)
                      : canUnlock
                          ? const Color(0xFFF3E5F5)
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getItemIcon(item['id']),
                  size: 36,
                  color: isUnlocked
                      ? const Color(0xFF4CAF50)
                      : canUnlock
                          ? const Color(0xFF9C27B0)
                          : Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              // 아이템 이름
              Text(
                item['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: canUnlock ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 상태 표시
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '보유중',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (!canUnlock)
                Text(
                  '레벨 ${item['unlockLevel']} 필요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: canAfford ? const Color(0xFFFFD700) : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['price']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getItemIcon(String itemId) {
    if (itemId.contains('bag')) return Icons.shopping_bag;
    if (itemId.contains('watch')) return Icons.watch;
    if (itemId.contains('accessory') || itemId.contains('necklace')) {
      return Icons.diamond;
    }
    if (itemId.contains('car')) return Icons.directions_car;
    if (itemId.contains('tv')) return Icons.tv;
    if (itemId.contains('fridge')) return Icons.kitchen;
    if (itemId.contains('console')) return Icons.sports_esports;
    if (itemId.contains('laptop')) return Icons.laptop;
    if (itemId.contains('home_theater')) return Icons.speaker;
    if (itemId.contains('room')) return Icons.meeting_room;
    if (itemId.contains('apt')) return Icons.apartment;
    if (itemId.contains('penthouse')) return Icons.villa;
    if (itemId.contains('mansion')) return Icons.castle;
    if (itemId.contains('travel')) return Icons.flight;
    return Icons.card_giftcard;
  }

  void _showPurchaseDialog(GameProvider provider, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getItemIcon(item['id']),
                size: 40,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('구매 가격: '),
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
                Text(
                  '${item['price']}',
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
              final success = provider.purchaseItem(
                item['id'] as String,
                item['price'] as int,
              );
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? '${item['name']}을(를) 구매했습니다!' : '구매에 실패했습니다.',
                  ),
                  backgroundColor: success ? const Color(0xFF4CAF50) : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}
