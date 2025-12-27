import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/game_service.dart';

/// 게임 상태 관리 Provider
class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  GameState _gameState = const GameState();
  Puzzle? _currentPuzzle;
  int _hintsUsed = 0;

  GameState get gameState => _gameState;
  Puzzle? get currentPuzzle => _currentPuzzle;
  int get hintsUsed => _hintsUsed;

  /// 레벨 시작
  void startLevel(int level) {
    _currentPuzzle = _gameService.startLevel(level);
    _hintsUsed = 0;
    _gameState = _gameState.copyWith(currentLevel: level);
    notifyListeners();
  }

  /// 셀 선택
  void selectCell(int row, int col) {
    if (_currentPuzzle == null) return;

    final cell = _currentPuzzle!.grid[row][col];

    // 이미 채워진 셀이면 글자 제거
    if (cell.state == CellState.filled) {
      _currentPuzzle = _gameService.removeLetter(_currentPuzzle!, row, col);
    } else if (cell.isSelectable) {
      _currentPuzzle = _gameService.selectCell(_currentPuzzle!, row, col);
    }

    notifyListeners();
  }

  /// 글자 배치
  void placeLetter(String letter) {
    if (_currentPuzzle == null) return;

    _currentPuzzle = _gameService.placeLetter(_currentPuzzle!, letter);

    // 퍼즐 완료 체크
    if (_currentPuzzle!.isCompleted) {
      _onLevelComplete();
    }

    notifyListeners();
  }

  /// 레벨 완료 처리
  void _onLevelComplete() {
    final score = _gameService.calculateLevelScore(
      _currentPuzzle!,
      hintsUsed: _hintsUsed,
    );
    final coins = _gameService.calculateCoins(score);
    final level = _currentPuzzle!.level;

    // 수집한 단어들 추가
    List<String> newCollectedWords = List.from(_gameState.collectedWords);
    for (var word in _currentPuzzle!.words) {
      if (!newCollectedWords.contains(word.text)) {
        newCollectedWords.add(word.text);
      }
    }

    // 완료된 레벨 추가
    List<int> newCompletedLevels = List.from(_gameState.completedLevels);
    if (!newCompletedLevels.contains(level)) {
      newCompletedLevels.add(level);
    }

    // 다음 레벨 해금
    int newMaxLevel = _gameState.maxUnlockedLevel;
    if (level >= newMaxLevel && level < 50) {
      newMaxLevel = level + 1;
    }

    _gameState = _gameState.copyWith(
      totalScore: _gameState.totalScore + score,
      totalCoins: _gameState.totalCoins + coins,
      completedLevels: newCompletedLevels,
      collectedWords: newCollectedWords,
      maxUnlockedLevel: newMaxLevel,
    );
  }

  /// 힌트: 글자 공개
  void useHintRevealLetter() {
    if (_currentPuzzle == null) return;
    if (_gameState.totalCoins < 10) return; // 코인 부족

    _currentPuzzle = _gameService.useHintRevealLetter(_currentPuzzle!);
    _hintsUsed++;
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins - 10,
    );
    notifyListeners();
  }

  /// 힌트: 단어 뜻 보기
  String? getWordMeaning(int row, int col) {
    if (_currentPuzzle == null) return null;
    return _gameService.getWordMeaning(_currentPuzzle!, row, col);
  }

  /// 힌트: 틀린 글자 표시
  void useHintShowWrong() {
    if (_currentPuzzle == null) return;
    if (_gameState.totalCoins < 5) return;

    _currentPuzzle = _gameService.showWrongLetters(_currentPuzzle!);
    _hintsUsed++;
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins - 5,
    );
    notifyListeners();
  }

  /// 오답 단어 추가
  void addWrongWord(String word) {
    if (_gameState.wrongWords.contains(word)) return;

    List<String> newWrongWords = List.from(_gameState.wrongWords)..add(word);
    _gameState = _gameState.copyWith(wrongWords: newWrongWords);
    notifyListeners();
  }

  /// 코인 추가 (광고 보상 등)
  void addCoins(int amount) {
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins + amount,
    );
    notifyListeners();
  }

  /// 설정 변경
  void toggleSfx() {
    _gameState = _gameState.copyWith(sfxEnabled: !_gameState.sfxEnabled);
    notifyListeners();
  }

  void toggleBgm() {
    _gameState = _gameState.copyWith(bgmEnabled: !_gameState.bgmEnabled);
    notifyListeners();
  }
}
