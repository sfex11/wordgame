import 'dart:math';
import '../models/models.dart';
import 'puzzle_generator.dart';

/// 일일 도전 퍼즐 서비스
class DailyChallengeService {
  final PuzzleGenerator _generator = PuzzleGenerator();

  /// 오늘의 시드 생성 (날짜 기반)
  int _getTodaySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// 오늘의 도전 퍼즐 생성
  Puzzle generateDailyChallenge() {
    final seed = _getTodaySeed();
    final random = Random(seed);

    // 일일 도전은 중간 난이도 (6개 단어, 7x7 격자, 30% 힌트)
    const wordCount = 6;
    const gridSize = 7;
    const hintPercent = 30;

    return _generator.generatePuzzleWithConfig(
      -1, // 일일 도전 레벨 표시 (-1)
      wordCount,
      gridSize,
      hintPercent,
    );
  }

  /// 일일 도전 완료 여부 확인
  bool isDailyChallengeCompleted(DateTime? lastCompletedDate) {
    if (lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completed = DateTime(
      lastCompletedDate.year,
      lastCompletedDate.month,
      lastCompletedDate.day,
    );

    return today.isAtSameMomentAs(completed);
  }

  /// 일일 도전 보상 계산
  int calculateDailyReward(int score) {
    // 기본 보상 + 점수 보너스
    const baseReward = 30;
    final scoreBonus = score ~/ 5;
    return baseReward + scoreBonus;
  }

  /// 오늘 날짜 문자열
  String getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }
}
