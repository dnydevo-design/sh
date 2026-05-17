import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';

/// Wraps Google Mobile Ads rewarded ad lifecycle.
class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isAdLoaded => _rewardedAd != null;
  bool get isLoading => _isLoading;

  /// Pre-load a rewarded ad so it's ready when the user taps "Watch Ad".
  Future<void> loadRewardedAd() async {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Show the rewarded ad. Calls [onRewarded] when the user earns the reward.
  /// Calls [onDismissed] when the ad is closed (regardless of reward).
  Future<void> showRewardedAd({
    required void Function() onRewarded,
    void Function()? onDismissed,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        // Pre-load the next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    await ad.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
