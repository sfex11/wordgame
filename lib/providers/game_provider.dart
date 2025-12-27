import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../data/level_config.dart';

/// 게임 상태 관리 Provider
class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final AudioService _audioService = AudioService();
  StorageService? _storageService;

  GameState _gameState = const GameState();
  Puzzle? _currentPuzzle;
  int _hintsUsed = 0;
  bool _isInitialized = false;
  int _attendanceReward = 0; // 오늘 받을 출석 보상

  GameState get gameState => _gameState;
  Puzzle? get currentPuzzle => _currentPuzzle;
  int get hintsUsed => _hintsUsed;
  bool get isInitialized => _isInitialized;
  int get attendanceReward => _attendanceReward;

  /// 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _storageService = await StorageService.getInstance();
    _gameState = _storageService!.loadGameState();

    // 오디오 설정 로드
    _audioService.loadSettings(
      bgmEnabled: _gameState.bgmEnabled,
      sfxEnabled: _gameState.sfxEnabled,
    );

    // 메인 BGM 시작
    _audioService.playBgm(AudioService.bgmMain);

    // 출석 체크
    await _checkDailyAttendance();

    _isInitialized = true;
    notifyListeners();
  }

  /// 일일 출석 체크
  Future<void> _checkDailyAttendance() async {
    if (_storageService == null) return;

    final newStreak = await _storageService!.checkDailyAttendance(_gameState);

    if (newStreak > 0) {
      // 오늘 첫 접속
      _attendanceReward = _storageService!.calculateAttendanceReward(newStreak);

      _gameState = _gameState.copyWith(
        dailyStreak: newStreak,
        lastPlayDate: DateTime.now(),
      );
    } else {
      // 오늘 이미 접속함
      _attendanceReward = 0;
    }
  }

  /// 출석 보상 수령
  void claimAttendanceReward() {
    if (_attendanceReward > 0) {
      _gameState = _gameState.copyWith(
        totalCoins: _gameState.totalCoins + _attendanceReward,
      );
      _attendanceReward = 0;
      _saveGameState();
      notifyListeners();
    }
  }

  /// 게임 상태 저장
  Future<void> _saveGameState() async {
    await _storageService?.saveGameState(_gameState);
  }

  /// 레벨 시작
  void startLevel(int level) {
    final config = getLevelConfig(level);
    _currentPuzzle = _gameService.startLevelWithConfig(
      level,
      config.wordCount,
      config.gridSize,
      config.hintPercent,
    );
    _hintsUsed = 0;
    _gameState = _gameState.copyWith(currentLevel: level);

    // 게임 BGM으로 전환
    _audioService.playBgm(AudioService.bgmGame);

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

    final prevCompletedWords = _currentPuzzle!.completedWordCount;
    _currentPuzzle = _gameService.placeLetter(_currentPuzzle!, letter);

    // 글자 배치 효과음
    _audioService.playSfx(AudioService.sfxLetterPlace);

    // 단어 완성 체크
    if (_currentPuzzle!.completedWordCount > prevCompletedWords) {
      _audioService.playSfx(AudioService.sfxWordComplete);
    }

    // 퍼즐 완료 체크
    if (_currentPuzzle!.isCompleted) {
      _onLevelComplete();
    }

    notifyListeners();
  }

  /// 레벨 완료 처리
  void _onLevelComplete() {
    final level = _currentPuzzle!.level;
    final config = getLevelConfig(level);

    final score = _gameService.calculateLevelScore(
      _currentPuzzle!,
      hintsUsed: _hintsUsed,
    );

    // 기본 보상 + 점수 보상
    final coins = config.clearReward + _gameService.calculateCoins(score);

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

    // 레벨 완료 효과음 및 BGM
    _audioService.playSfx(AudioService.sfxLevelComplete);
    _audioService.playBgm(AudioService.bgmVictory);

    // 자동 저장
    _saveGameState();
  }

  /// 홈으로 돌아갈 때 메인 BGM으로 복귀
  void returnToHome() {
    _currentPuzzle = null;
    _audioService.playBgm(AudioService.bgmMain);
    notifyListeners();
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

    _audioService.playSfx(AudioService.sfxHintUse);

    _saveGameState();
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

    _audioService.playSfx(AudioService.sfxHintUse);

    _saveGameState();
    notifyListeners();
  }

  /// 오답 단어 추가
  void addWrongWord(String word) {
    if (_gameState.wrongWords.contains(word)) return;

    List<String> newWrongWords = List.from(_gameState.wrongWords)..add(word);
    _gameState = _gameState.copyWith(wrongWords: newWrongWords);
    _saveGameState();
    notifyListeners();
  }

  /// 오답 단어 제거 (복습 완료)
  void removeWrongWord(String word) {
    List<String> newWrongWords = List.from(_gameState.wrongWords)..remove(word);
    _gameState = _gameState.copyWith(wrongWords: newWrongWords);
    _saveGameState();
    notifyListeners();
  }

  /// 코인 추가 (광고 보상 등)
  void addCoins(int amount) {
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins + amount,
    );
    _saveGameState();
    notifyListeners();
  }

  /// 아이템 구매
  bool purchaseItem(String itemId, int price) {
    if (_gameState.totalCoins < price) return false;
    if (_gameState.unlockedItems.contains(itemId)) return false;

    List<String> newItems = List.from(_gameState.unlockedItems)..add(itemId);
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins - price,
      unlockedItems: newItems,
    );

    _audioService.playSfx(AudioService.sfxPurchase);

    _saveGameState();
    notifyListeners();
    return true;
  }

  /// 캐릭터 해금
  bool unlockCharacter(String characterId, int price) {
    if (_gameState.totalCoins < price) return false;
    if (_gameState.unlockedCharacters.contains(characterId)) return false;

    List<String> newCharacters = List.from(_gameState.unlockedCharacters)
      ..add(characterId);
    _gameState = _gameState.copyWith(
      totalCoins: _gameState.totalCoins - price,
      unlockedCharacters: newCharacters,
    );

    _audioService.playSfx(AudioService.sfxUnlock);

    _saveGameState();
    notifyListeners();
    return true;
  }

  /// 캐릭터 선택
  void selectCharacter(String characterId) {
    if (!_gameState.unlockedCharacters.contains(characterId)) return;

    _gameState = _gameState.copyWith(selectedCharacter: characterId);
    _saveGameState();
    notifyListeners();
  }

  /// 설정 변경
  void toggleSfx() {
    _gameState = _gameState.copyWith(sfxEnabled: !_gameState.sfxEnabled);
    _audioService.setSfxEnabled(_gameState.sfxEnabled);
    _saveGameState();
    notifyListeners();
  }

  void toggleBgm() {
    _gameState = _gameState.copyWith(bgmEnabled: !_gameState.bgmEnabled);
    _audioService.setBgmEnabled(_gameState.bgmEnabled);
    _saveGameState();
    notifyListeners();
  }

  /// 데이터 초기화
  Future<void> resetAllData() async {
    await _storageService?.clearAllData();
    _gameState = const GameState();
    _currentPuzzle = null;
    _hintsUsed = 0;
    notifyListeners();
  }
}
