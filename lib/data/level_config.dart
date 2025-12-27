/// 레벨별 설정 데이터
class LevelConfig {
  final int level;
  final int wordCount;
  final int gridSize;
  final int hintPercent;
  final int clearReward; // 클리어 시 기본 코인 보상

  const LevelConfig({
    required this.level,
    required this.wordCount,
    required this.gridSize,
    required this.hintPercent,
    required this.clearReward,
  });
}

/// 50레벨 설정
const List<LevelConfig> levelConfigs = [
  // 레벨 1~10: 쉬움 (5x5, 4단어, 50% 힌트)
  LevelConfig(level: 1, wordCount: 4, gridSize: 5, hintPercent: 50, clearReward: 15),
  LevelConfig(level: 2, wordCount: 4, gridSize: 5, hintPercent: 50, clearReward: 15),
  LevelConfig(level: 3, wordCount: 4, gridSize: 5, hintPercent: 50, clearReward: 15),
  LevelConfig(level: 4, wordCount: 4, gridSize: 5, hintPercent: 45, clearReward: 16),
  LevelConfig(level: 5, wordCount: 4, gridSize: 5, hintPercent: 45, clearReward: 16),
  LevelConfig(level: 6, wordCount: 4, gridSize: 5, hintPercent: 45, clearReward: 17),
  LevelConfig(level: 7, wordCount: 4, gridSize: 5, hintPercent: 40, clearReward: 17),
  LevelConfig(level: 8, wordCount: 4, gridSize: 5, hintPercent: 40, clearReward: 18),
  LevelConfig(level: 9, wordCount: 4, gridSize: 5, hintPercent: 40, clearReward: 18),
  LevelConfig(level: 10, wordCount: 4, gridSize: 5, hintPercent: 35, clearReward: 20),

  // 레벨 11~20: 보통 (6x6, 5단어, 40% 힌트)
  LevelConfig(level: 11, wordCount: 5, gridSize: 6, hintPercent: 40, clearReward: 22),
  LevelConfig(level: 12, wordCount: 5, gridSize: 6, hintPercent: 40, clearReward: 22),
  LevelConfig(level: 13, wordCount: 5, gridSize: 6, hintPercent: 38, clearReward: 23),
  LevelConfig(level: 14, wordCount: 5, gridSize: 6, hintPercent: 38, clearReward: 23),
  LevelConfig(level: 15, wordCount: 5, gridSize: 6, hintPercent: 35, clearReward: 24),
  LevelConfig(level: 16, wordCount: 5, gridSize: 6, hintPercent: 35, clearReward: 24),
  LevelConfig(level: 17, wordCount: 5, gridSize: 6, hintPercent: 33, clearReward: 25),
  LevelConfig(level: 18, wordCount: 5, gridSize: 6, hintPercent: 33, clearReward: 25),
  LevelConfig(level: 19, wordCount: 5, gridSize: 6, hintPercent: 30, clearReward: 26),
  LevelConfig(level: 20, wordCount: 5, gridSize: 6, hintPercent: 30, clearReward: 28),

  // 레벨 21~30: 어려움 (7x7, 6단어, 30% 힌트)
  LevelConfig(level: 21, wordCount: 6, gridSize: 7, hintPercent: 35, clearReward: 30),
  LevelConfig(level: 22, wordCount: 6, gridSize: 7, hintPercent: 35, clearReward: 30),
  LevelConfig(level: 23, wordCount: 6, gridSize: 7, hintPercent: 33, clearReward: 31),
  LevelConfig(level: 24, wordCount: 6, gridSize: 7, hintPercent: 33, clearReward: 31),
  LevelConfig(level: 25, wordCount: 6, gridSize: 7, hintPercent: 30, clearReward: 32),
  LevelConfig(level: 26, wordCount: 6, gridSize: 7, hintPercent: 30, clearReward: 32),
  LevelConfig(level: 27, wordCount: 6, gridSize: 7, hintPercent: 28, clearReward: 33),
  LevelConfig(level: 28, wordCount: 6, gridSize: 7, hintPercent: 28, clearReward: 33),
  LevelConfig(level: 29, wordCount: 6, gridSize: 7, hintPercent: 25, clearReward: 34),
  LevelConfig(level: 30, wordCount: 6, gridSize: 7, hintPercent: 25, clearReward: 36),

  // 레벨 31~40: 매우 어려움 (8x8, 7단어, 25% 힌트)
  LevelConfig(level: 31, wordCount: 7, gridSize: 8, hintPercent: 30, clearReward: 38),
  LevelConfig(level: 32, wordCount: 7, gridSize: 8, hintPercent: 30, clearReward: 38),
  LevelConfig(level: 33, wordCount: 7, gridSize: 8, hintPercent: 28, clearReward: 39),
  LevelConfig(level: 34, wordCount: 7, gridSize: 8, hintPercent: 28, clearReward: 39),
  LevelConfig(level: 35, wordCount: 7, gridSize: 8, hintPercent: 25, clearReward: 40),
  LevelConfig(level: 36, wordCount: 7, gridSize: 8, hintPercent: 25, clearReward: 40),
  LevelConfig(level: 37, wordCount: 7, gridSize: 8, hintPercent: 23, clearReward: 41),
  LevelConfig(level: 38, wordCount: 7, gridSize: 8, hintPercent: 23, clearReward: 41),
  LevelConfig(level: 39, wordCount: 7, gridSize: 8, hintPercent: 20, clearReward: 42),
  LevelConfig(level: 40, wordCount: 7, gridSize: 8, hintPercent: 20, clearReward: 45),

  // 레벨 41~50: 최고 난이도 (8x8, 8단어, 20% 힌트)
  LevelConfig(level: 41, wordCount: 8, gridSize: 8, hintPercent: 25, clearReward: 48),
  LevelConfig(level: 42, wordCount: 8, gridSize: 8, hintPercent: 25, clearReward: 48),
  LevelConfig(level: 43, wordCount: 8, gridSize: 8, hintPercent: 23, clearReward: 49),
  LevelConfig(level: 44, wordCount: 8, gridSize: 8, hintPercent: 23, clearReward: 49),
  LevelConfig(level: 45, wordCount: 8, gridSize: 8, hintPercent: 20, clearReward: 50),
  LevelConfig(level: 46, wordCount: 8, gridSize: 8, hintPercent: 20, clearReward: 50),
  LevelConfig(level: 47, wordCount: 8, gridSize: 8, hintPercent: 18, clearReward: 52),
  LevelConfig(level: 48, wordCount: 8, gridSize: 8, hintPercent: 18, clearReward: 52),
  LevelConfig(level: 49, wordCount: 8, gridSize: 8, hintPercent: 15, clearReward: 55),
  LevelConfig(level: 50, wordCount: 8, gridSize: 8, hintPercent: 15, clearReward: 60),
];

/// 레벨 설정 가져오기
LevelConfig getLevelConfig(int level) {
  if (level < 1 || level > 50) {
    return levelConfigs[0];
  }
  return levelConfigs[level - 1];
}

/// 캐릭터 해금 조건
const Map<String, Map<String, dynamic>> characterUnlockRequirements = {
  'default': {'level': 1, 'coins': 0},
  'student': {'level': 5, 'coins': 100},
  'office_worker': {'level': 10, 'coins': 200},
  'scientist': {'level': 20, 'coins': 500},
  'artist': {'level': 30, 'coins': 800},
  'ceo': {'level': 40, 'coins': 1200},
  'legend': {'level': 50, 'coins': 2000},
};

/// 수집 아이템 목록
const Map<String, List<Map<String, dynamic>>> collectibleItems = {
  'luxury': [
    {'id': 'bag_1', 'name': '명품 가방', 'price': 100, 'unlockLevel': 1},
    {'id': 'watch_1', 'name': '고급 시계', 'price': 200, 'unlockLevel': 5},
    {'id': 'accessory_1', 'name': '다이아 목걸이', 'price': 500, 'unlockLevel': 15},
    {'id': 'bag_2', 'name': '한정판 가방', 'price': 1000, 'unlockLevel': 25},
    {'id': 'watch_2', 'name': '럭셔리 시계', 'price': 2000, 'unlockLevel': 40},
  ],
  'car': [
    {'id': 'car_1', 'name': '경차', 'price': 150, 'unlockLevel': 3},
    {'id': 'car_2', 'name': '세단', 'price': 300, 'unlockLevel': 8},
    {'id': 'car_3', 'name': 'SUV', 'price': 600, 'unlockLevel': 18},
    {'id': 'car_4', 'name': '스포츠카', 'price': 1500, 'unlockLevel': 30},
    {'id': 'car_5', 'name': '슈퍼카', 'price': 3000, 'unlockLevel': 45},
  ],
  'electronics': [
    {'id': 'tv_1', 'name': 'TV', 'price': 80, 'unlockLevel': 2},
    {'id': 'fridge_1', 'name': '냉장고', 'price': 120, 'unlockLevel': 4},
    {'id': 'console_1', 'name': '게임기', 'price': 250, 'unlockLevel': 10},
    {'id': 'laptop_1', 'name': '노트북', 'price': 400, 'unlockLevel': 20},
    {'id': 'home_theater', 'name': '홈시어터', 'price': 1000, 'unlockLevel': 35},
  ],
  'realestate': [
    {'id': 'room_1', 'name': '원룸', 'price': 500, 'unlockLevel': 7},
    {'id': 'apt_1', 'name': '아파트', 'price': 1500, 'unlockLevel': 15},
    {'id': 'apt_2', 'name': '고급 아파트', 'price': 3000, 'unlockLevel': 28},
    {'id': 'penthouse', 'name': '펜트하우스', 'price': 5000, 'unlockLevel': 38},
    {'id': 'mansion', 'name': '대저택', 'price': 10000, 'unlockLevel': 50},
  ],
  'travel': [
    {'id': 'travel_1', 'name': '제주도 여행', 'price': 100, 'unlockLevel': 5},
    {'id': 'travel_2', 'name': '일본 여행', 'price': 300, 'unlockLevel': 12},
    {'id': 'travel_3', 'name': '유럽 여행', 'price': 800, 'unlockLevel': 22},
    {'id': 'travel_4', 'name': '세계일주', 'price': 2000, 'unlockLevel': 35},
    {'id': 'travel_5', 'name': '우주여행', 'price': 5000, 'unlockLevel': 48},
  ],
};

/// 주간 배지 목표
const List<Map<String, dynamic>> weeklyBadgeGoals = [
  {'id': 'badge_3', 'name': '3일 연속', 'days': 3, 'reward': 30},
  {'id': 'badge_5', 'name': '5일 연속', 'days': 5, 'reward': 50},
  {'id': 'badge_7', 'name': '7일 연속', 'days': 7, 'reward': 100},
];
