import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/ad_service.dart';

enum UnlockableFeature { ultraSpeed, fastZip }

class AdController extends ChangeNotifier {
  AdController(this._adService, this._preferences) {
    _loadUnlockState();
    _adService.loadRewardedAd().then((_) => notifyListeners());
  }

  final AdService _adService;
  final SharedPreferences _preferences;
  final _audioPlayer = AudioPlayer();

  bool _isSupporter = false;
  bool _isAdShowing = false;
  DateTime? _ultraSpeedUnlockedUntil;
  DateTime? _fastZipUnlockedUntil;

  bool get isAdLoaded => _adService.isAdLoaded;
  bool get isAdLoading => _adService.isLoading;
  bool get isAdShowing => _isAdShowing;
  bool get isSupporter => _isSupporter;

  bool get isUltraSpeedUnlocked =>
      _ultraSpeedUnlockedUntil != null &&
      DateTime.now().isBefore(_ultraSpeedUnlockedUntil!);

  bool get isFastZipUnlocked =>
      _fastZipUnlockedUntil != null &&
      DateTime.now().isBefore(_fastZipUnlockedUntil!);

  bool isFeatureUnlocked(UnlockableFeature feature) {
    return switch (feature) {
      UnlockableFeature.ultraSpeed => isUltraSpeedUnlocked,
      UnlockableFeature.fastZip => isFastZipUnlocked,
    };
  }

  /// Show rewarded ad to unlock a feature for 1 hour.
  Future<void> unlockFeature(UnlockableFeature feature) async {
    if (!_adService.isAdLoaded) {
      await _adService.loadRewardedAd();
      notifyListeners();
      if (!_adService.isAdLoaded) return;
    }

    _isAdShowing = true;
    notifyListeners();

    await _adService.showRewardedAd(
      onRewarded: () {
        final unlockUntil = DateTime.now().add(const Duration(hours: 1));
        switch (feature) {
          case UnlockableFeature.ultraSpeed:
            _ultraSpeedUnlockedUntil = unlockUntil;
            _preferences.setString(
              AppConstants.ultraSpeedUnlockKey,
              unlockUntil.toIso8601String(),
            );
          case UnlockableFeature.fastZip:
            _fastZipUnlockedUntil = unlockUntil;
            _preferences.setString(
              AppConstants.fastZipUnlockKey,
              unlockUntil.toIso8601String(),
            );
        }
        _isSupporter = true;
        _playSuccessSound();
        notifyListeners();
      },
      onDismissed: () {
        _isAdShowing = false;
        notifyListeners();
      },
    );
  }

  /// Show a rewarded ad for the Support screen (supporter badge only).
  Future<void> watchSupportAd() async {
    if (!_adService.isAdLoaded) {
      await _adService.loadRewardedAd();
      notifyListeners();
      if (!_adService.isAdLoaded) return;
    }

    _isAdShowing = true;
    notifyListeners();

    await _adService.showRewardedAd(
      onRewarded: () {
        _isSupporter = true;
        _playSuccessSound();
        notifyListeners();
      },
      onDismissed: () {
        _isAdShowing = false;
        notifyListeners();
      },
    );
  }

  /// Reload ad if needed (e.g., when returning to a screen).
  Future<void> ensureAdLoaded() async {
    if (!_adService.isAdLoaded && !_adService.isLoading) {
      await _adService.loadRewardedAd();
      notifyListeners();
    }
  }

  void _loadUnlockState() {
    final ultraStr = _preferences.getString(AppConstants.ultraSpeedUnlockKey);
    if (ultraStr != null) {
      _ultraSpeedUnlockedUntil = DateTime.tryParse(ultraStr);
    }
    final zipStr = _preferences.getString(AppConstants.fastZipUnlockKey);
    if (zipStr != null) {
      _fastZipUnlockedUntil = DateTime.tryParse(zipStr);
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Sound file not available — silently ignore
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _adService.dispose();
    super.dispose();
  }
}
