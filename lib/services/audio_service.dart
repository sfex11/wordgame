import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 오디오 서비스 - 배경음악 및 효과음 관리
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  bool _isInitialized = false;

  double _bgmVolume = 0.5;
  double _sfxVolume = 0.7;

  // 효과음 타입
  static const String sfxButtonClick = 'button_click';
  static const String sfxLetterPlace = 'letter_place';
  static const String sfxWordComplete = 'word_complete';
  static const String sfxLevelComplete = 'level_complete';
  static const String sfxWrongLetter = 'wrong_letter';
  static const String sfxHintUse = 'hint_use';
  static const String sfxCoinEarn = 'coin_earn';
  static const String sfxPurchase = 'purchase';
  static const String sfxUnlock = 'unlock';
  static const String sfxBadgeEarn = 'badge_earn';

  // 배경음악 타입
  static const String bgmMain = 'main_theme';
  static const String bgmGame = 'game_theme';
  static const String bgmVictory = 'victory_theme';

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 배경음악 플레이어 설정
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmVolume);

      // 효과음 플레이어 설정
      await _sfxPlayer.setVolume(_sfxVolume);

      _isInitialized = true;
      debugPrint('AudioService initialized');
    } catch (e) {
      debugPrint('AudioService initialization error: $e');
    }
  }

  /// 설정 로드
  void loadSettings({
    required bool bgmEnabled,
    required bool sfxEnabled,
    double bgmVolume = 0.5,
    double sfxVolume = 0.7,
  }) {
    _isBgmEnabled = bgmEnabled;
    _isSfxEnabled = sfxEnabled;
    _bgmVolume = bgmVolume;
    _sfxVolume = sfxVolume;

    _bgmPlayer.setVolume(_isBgmEnabled ? _bgmVolume : 0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  /// 배경음악 재생
  Future<void> playBgm(String bgmType) async {
    if (!_isBgmEnabled) return;

    try {
      final assetPath = _getBgmAssetPath(bgmType);
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(assetPath));
      debugPrint('Playing BGM: $bgmType');
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  /// 배경음악 정지
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM stop error: $e');
    }
  }

  /// 배경음악 일시정지
  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('BGM pause error: $e');
    }
  }

  /// 배경음악 재개
  Future<void> resumeBgm() async {
    if (!_isBgmEnabled) return;

    try {
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('BGM resume error: $e');
    }
  }

  /// 효과음 재생
  Future<void> playSfx(String sfxType) async {
    if (!_isSfxEnabled) return;

    try {
      final assetPath = _getSfxAssetPath(sfxType);
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
      debugPrint('Playing SFX: $sfxType');
    } catch (e) {
      debugPrint('SFX play error: $e');
    }
  }

  /// 배경음악 on/off
  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    if (enabled) {
      _bgmPlayer.setVolume(_bgmVolume);
    } else {
      _bgmPlayer.setVolume(0);
    }
  }

  /// 효과음 on/off
  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  /// 배경음악 볼륨 설정
  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    if (_isBgmEnabled) {
      _bgmPlayer.setVolume(_bgmVolume);
    }
  }

  /// 효과음 볼륨 설정
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  /// 현재 설정 상태
  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  /// BGM 에셋 경로 (Kenney UI Audio 기반)
  String _getBgmAssetPath(String bgmType) {
    // assets/audio/bgm/ 폴더에 배치
    switch (bgmType) {
      case bgmMain:
        return 'audio/bgm/main_theme.ogg';
      case bgmGame:
        return 'audio/bgm/game_theme.ogg';
      case bgmVictory:
        return 'audio/bgm/victory_theme.ogg';
      default:
        return 'audio/bgm/main_theme.ogg';
    }
  }

  /// SFX 에셋 경로 (Kenney UI Audio 기반)
  String _getSfxAssetPath(String sfxType) {
    // assets/audio/sfx/ 폴더에 배치
    // Kenney UI Audio 파일명 매핑
    switch (sfxType) {
      case sfxButtonClick:
        return 'audio/sfx/click1.ogg';
      case sfxLetterPlace:
        return 'audio/sfx/switch2.ogg';
      case sfxWordComplete:
        return 'audio/sfx/confirmation_001.ogg';
      case sfxLevelComplete:
        return 'audio/sfx/confirmation_002.ogg';
      case sfxWrongLetter:
        return 'audio/sfx/error_004.ogg';
      case sfxHintUse:
        return 'audio/sfx/maximize_006.ogg';
      case sfxCoinEarn:
        return 'audio/sfx/coin_001.ogg';
      case sfxPurchase:
        return 'audio/sfx/confirmation_003.ogg';
      case sfxUnlock:
        return 'audio/sfx/unlock_001.ogg';
      case sfxBadgeEarn:
        return 'audio/sfx/jingle_achievement.ogg';
      default:
        return 'audio/sfx/click1.ogg';
    }
  }

  /// 리소스 해제
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
