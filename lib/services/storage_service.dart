import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// 로컬 저장소 서비스
class StorageService {
  static const String _gameStateBox = 'game_state';
  static const String _gameStateKey = 'state';
  static const String _settingsBox = 'settings';

  static StorageService? _instance;
  late Box _stateBox;
  late Box _settingsBox;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    await Hive.initFlutter();
    _stateBox = await Hive.openBox(_gameStateBox);
    _settingsBox = await Hive.openBox(_settingsBox);
  }

  /// 게임 상태 저장
  Future<void> saveGameState(GameState state) async {
    final json = jsonEncode(state.toJson());
    await _stateBox.put(_gameStateKey, json);
  }

  /// 게임 상태 로드
  GameState loadGameState() {
    final json = _stateBox.get(_gameStateKey);
    if (json == null) {
      return const GameState();
    }
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return GameState.fromJson(map);
    } catch (e) {
      return const GameState();
    }
  }

  /// 설정 저장
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// 설정 로드
  T? loadSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// 출석 체크
  Future<int> checkDailyAttendance(GameState state) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (state.lastPlayDate == null) {
      return 1; // 첫 출석
    }

    final lastPlay = DateTime(
      state.lastPlayDate!.year,
      state.lastPlayDate!.month,
      state.lastPlayDate!.day,
    );

    final difference = today.difference(lastPlay).inDays;

    if (difference == 0) {
      return 0; // 오늘 이미 출석함
    } else if (difference == 1) {
      return state.dailyStreak + 1; // 연속 출석
    } else {
      return 1; // 연속 끊김, 다시 시작
    }
  }

  /// 출석 보상 계산
  int calculateAttendanceReward(int streak) {
    // 연속 출석에 따른 보상
    if (streak >= 7) return 50;
    if (streak >= 5) return 30;
    if (streak >= 3) return 20;
    return 10;
  }

  /// 모든 데이터 초기화
  Future<void> clearAllData() async {
    await _stateBox.clear();
    await _settingsBox.clear();
  }
}
