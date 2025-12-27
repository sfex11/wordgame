import 'package:equatable/equatable.dart';

/// 전체 게임 상태 모델
class GameState extends Equatable {
  final int currentLevel;
  final int maxUnlockedLevel;
  final int totalCoins;
  final int totalScore;
  final List<int> completedLevels;
  final List<String> collectedWords;      // 수집한 단어들
  final List<String> wrongWords;          // 틀린 단어들 (복습용)
  final List<String> unlockedCharacters;  // 해금된 캐릭터들
  final String selectedCharacter;
  final List<String> unlockedItems;       // 해금된 수집 아이템들
  final int dailyStreak;                  // 연속 출석 일수
  final DateTime? lastPlayDate;
  final bool sfxEnabled;
  final bool bgmEnabled;

  const GameState({
    this.currentLevel = 1,
    this.maxUnlockedLevel = 1,
    this.totalCoins = 0,
    this.totalScore = 0,
    this.completedLevels = const [],
    this.collectedWords = const [],
    this.wrongWords = const [],
    this.unlockedCharacters = const ['default'],
    this.selectedCharacter = 'default',
    this.unlockedItems = const [],
    this.dailyStreak = 0,
    this.lastPlayDate,
    this.sfxEnabled = true,
    this.bgmEnabled = true,
  });

  bool isLevelUnlocked(int level) => level <= maxUnlockedLevel;
  bool isLevelCompleted(int level) => completedLevels.contains(level);

  GameState copyWith({
    int? currentLevel,
    int? maxUnlockedLevel,
    int? totalCoins,
    int? totalScore,
    List<int>? completedLevels,
    List<String>? collectedWords,
    List<String>? wrongWords,
    List<String>? unlockedCharacters,
    String? selectedCharacter,
    List<String>? unlockedItems,
    int? dailyStreak,
    DateTime? lastPlayDate,
    bool? sfxEnabled,
    bool? bgmEnabled,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      maxUnlockedLevel: maxUnlockedLevel ?? this.maxUnlockedLevel,
      totalCoins: totalCoins ?? this.totalCoins,
      totalScore: totalScore ?? this.totalScore,
      completedLevels: completedLevels ?? this.completedLevels,
      collectedWords: collectedWords ?? this.collectedWords,
      wrongWords: wrongWords ?? this.wrongWords,
      unlockedCharacters: unlockedCharacters ?? this.unlockedCharacters,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      unlockedItems: unlockedItems ?? this.unlockedItems,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'maxUnlockedLevel': maxUnlockedLevel,
      'totalCoins': totalCoins,
      'totalScore': totalScore,
      'completedLevels': completedLevels,
      'collectedWords': collectedWords,
      'wrongWords': wrongWords,
      'unlockedCharacters': unlockedCharacters,
      'selectedCharacter': selectedCharacter,
      'unlockedItems': unlockedItems,
      'dailyStreak': dailyStreak,
      'lastPlayDate': lastPlayDate?.toIso8601String(),
      'sfxEnabled': sfxEnabled,
      'bgmEnabled': bgmEnabled,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentLevel: json['currentLevel'] ?? 1,
      maxUnlockedLevel: json['maxUnlockedLevel'] ?? 1,
      totalCoins: json['totalCoins'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      completedLevels: List<int>.from(json['completedLevels'] ?? []),
      collectedWords: List<String>.from(json['collectedWords'] ?? []),
      wrongWords: List<String>.from(json['wrongWords'] ?? []),
      unlockedCharacters: List<String>.from(json['unlockedCharacters'] ?? ['default']),
      selectedCharacter: json['selectedCharacter'] ?? 'default',
      unlockedItems: List<String>.from(json['unlockedItems'] ?? []),
      dailyStreak: json['dailyStreak'] ?? 0,
      lastPlayDate: json['lastPlayDate'] != null
          ? DateTime.parse(json['lastPlayDate'])
          : null,
      sfxEnabled: json['sfxEnabled'] ?? true,
      bgmEnabled: json['bgmEnabled'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        maxUnlockedLevel,
        totalCoins,
        totalScore,
        completedLevels,
        collectedWords,
        wrongWords,
        unlockedCharacters,
        selectedCharacter,
        unlockedItems,
        dailyStreak,
        lastPlayDate,
        sfxEnabled,
        bgmEnabled,
      ];
}
