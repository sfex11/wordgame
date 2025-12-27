import 'package:flutter/foundation.dart';

/// 광고 서비스 - AdMob 통합 준비
///
/// 실제 AdMob 연동시 google_mobile_ads 패키지 필요
/// pubspec.yaml에 추가: google_mobile_ads: ^3.0.0
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool _isTestMode = true; // 개발 중에는 테스트 모드

  // AdMob 광고 단위 ID (테스트용)
  // 실제 배포시 실제 광고 ID로 교체 필요
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // 실제 광고 ID (배포시 교체)
  String _bannerAdUnitId = '';
  String _interstitialAdUnitId = '';
  String _rewardedAdUnitId = '';

  // 광고 로드 상태
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  // 광고 표시 쿨다운 (초)
  static const int interstitialCooldown = 60;
  static const int rewardedCooldown = 30;

  DateTime? _lastInterstitialTime;
  DateTime? _lastRewardedTime;

  /// 초기화
  Future<void> initialize({bool testMode = true}) async {
    if (_isInitialized) return;

    _isTestMode = testMode;

    try {
      // TODO: 실제 AdMob 초기화
      // await MobileAds.instance.initialize();

      if (_isTestMode) {
        _bannerAdUnitId = _testBannerAdUnitId;
        _interstitialAdUnitId = _testInterstitialAdUnitId;
        _rewardedAdUnitId = _testRewardedAdUnitId;
      }

      _isInitialized = true;
      debugPrint('AdService initialized (testMode: $_isTestMode)');

      // 전면 광고 미리 로드
      await loadInterstitialAd();
      await loadRewardedAd();
    } catch (e) {
      debugPrint('AdService initialization error: $e');
    }
  }

  /// 실제 광고 ID 설정 (배포용)
  void setAdUnitIds({
    required String bannerId,
    required String interstitialId,
    required String rewardedId,
  }) {
    _bannerAdUnitId = bannerId;
    _interstitialAdUnitId = interstitialId;
    _rewardedAdUnitId = rewardedId;
    _isTestMode = false;
  }

  /// 배너 광고 로드
  Future<void> loadBannerAd() async {
    if (!_isInitialized) return;

    try {
      // TODO: 실제 배너 광고 로드
      // _bannerAd = BannerAd(
      //   adUnitId: _bannerAdUnitId,
      //   size: AdSize.banner,
      //   request: const AdRequest(),
      //   listener: BannerAdListener(...),
      // );
      // await _bannerAd?.load();

      _isBannerLoaded = true;
      debugPrint('Banner ad loaded');
    } catch (e) {
      debugPrint('Banner ad load error: $e');
    }
  }

  /// 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) return;

    try {
      // TODO: 실제 전면 광고 로드
      // await InterstitialAd.load(
      //   adUnitId: _interstitialAdUnitId,
      //   request: const AdRequest(),
      //   adLoadCallback: InterstitialAdLoadCallback(...),
      // );

      _isInterstitialLoaded = true;
      debugPrint('Interstitial ad loaded');
    } catch (e) {
      debugPrint('Interstitial ad load error: $e');
    }
  }

  /// 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) return;

    try {
      // TODO: 실제 보상형 광고 로드
      // await RewardedAd.load(
      //   adUnitId: _rewardedAdUnitId,
      //   request: const AdRequest(),
      //   rewardedAdLoadCallback: RewardedAdLoadCallback(...),
      // );

      _isRewardedLoaded = true;
      debugPrint('Rewarded ad loaded');
    } catch (e) {
      debugPrint('Rewarded ad load error: $e');
    }
  }

  /// 전면 광고 표시 가능 여부
  bool canShowInterstitial() {
    if (!_isInterstitialLoaded) return false;

    if (_lastInterstitialTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialTime!).inSeconds;
      if (elapsed < interstitialCooldown) return false;
    }

    return true;
  }

  /// 전면 광고 표시 (레벨 완료 후)
  Future<bool> showInterstitialAd() async {
    if (!canShowInterstitial()) {
      debugPrint('Interstitial ad not ready or in cooldown');
      return false;
    }

    try {
      // TODO: 실제 전면 광고 표시
      // await _interstitialAd?.show();

      _lastInterstitialTime = DateTime.now();
      _isInterstitialLoaded = false;

      debugPrint('Interstitial ad shown');

      // 다음 광고 미리 로드
      loadInterstitialAd();

      return true;
    } catch (e) {
      debugPrint('Interstitial ad show error: $e');
      return false;
    }
  }

  /// 보상형 광고 표시 가능 여부
  bool canShowRewarded() {
    if (!_isRewardedLoaded) return false;

    if (_lastRewardedTime != null) {
      final elapsed = DateTime.now().difference(_lastRewardedTime!).inSeconds;
      if (elapsed < rewardedCooldown) return false;
    }

    return true;
  }

  /// 보상형 광고 표시 (힌트 획득, 코인 획득 등)
  ///
  /// [onRewarded] 광고 시청 완료시 호출되는 콜백
  /// [rewardAmount] 보상 코인량 (기본 50)
  Future<bool> showRewardedAd({
    required Function(int rewardAmount) onRewarded,
    int rewardAmount = 50,
  }) async {
    if (!canShowRewarded()) {
      debugPrint('Rewarded ad not ready or in cooldown');
      return false;
    }

    try {
      // TODO: 실제 보상형 광고 표시
      // await _rewardedAd?.show(
      //   onUserEarnedReward: (ad, reward) {
      //     onRewarded(rewardAmount);
      //   },
      // );

      // 테스트 모드에서는 바로 보상 지급
      if (_isTestMode) {
        await Future.delayed(const Duration(seconds: 1));
        onRewarded(rewardAmount);
      }

      _lastRewardedTime = DateTime.now();
      _isRewardedLoaded = false;

      debugPrint('Rewarded ad shown, reward: $rewardAmount');

      // 다음 광고 미리 로드
      loadRewardedAd();

      return true;
    } catch (e) {
      debugPrint('Rewarded ad show error: $e');
      return false;
    }
  }

  /// 배너 광고 위젯 가져오기
  ///
  /// 실제 구현시 AdWidget 반환
  dynamic getBannerAdWidget() {
    if (!_isBannerLoaded) return null;

    // TODO: 실제 배너 위젯 반환
    // return AdWidget(ad: _bannerAd!);

    return null;
  }

  /// 광고 상태
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  bool get isTestMode => _isTestMode;

  /// 다음 전면 광고까지 남은 시간 (초)
  int get interstitialCooldownRemaining {
    if (_lastInterstitialTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastInterstitialTime!).inSeconds;
    return (interstitialCooldown - elapsed).clamp(0, interstitialCooldown);
  }

  /// 다음 보상형 광고까지 남은 시간 (초)
  int get rewardedCooldownRemaining {
    if (_lastRewardedTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastRewardedTime!).inSeconds;
    return (rewardedCooldown - elapsed).clamp(0, rewardedCooldown);
  }

  /// 리소스 해제
  void dispose() {
    // TODO: 광고 리소스 해제
    // _bannerAd?.dispose();
    // _interstitialAd?.dispose();
    // _rewardedAd?.dispose();
  }
}

/// 광고 표시 위치 타입
enum AdPlacement {
  levelComplete,    // 레벨 완료 후 전면 광고
  hintReward,       // 힌트 획득 보상형 광고
  coinReward,       // 코인 획득 보상형 광고
  continueGame,     // 게임 계속하기 보상형 광고
}

/// 광고 보상 타입
enum AdRewardType {
  coins,            // 코인 보상
  hint,             // 힌트 보상
  extraLife,        // 추가 기회
}
