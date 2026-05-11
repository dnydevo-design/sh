import 'package:flutter/material.dart';

import '../../data/services/profile_service.dart';
import '../../domain/entities/trusted_device.dart';
import '../../domain/entities/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._profileService);

  final ProfileService _profileService;

  UserProfile? _profile;
  List<TrustedDevice> _trustedDevices = const [];
  bool _isLoaded = false;

  UserProfile? get profile => _profile;
  List<TrustedDevice> get trustedDevices => List.unmodifiable(_trustedDevices);
  bool get isLoaded => _isLoaded;
  bool get hasProfile => _profile != null;
  String get endpointName => _profile?.username ?? 'Fast Share';

  void load() {
    _profile = _profileService.loadProfile();
    _trustedDevices = _profileService.loadTrustedDevices();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> save({
    required String username,
    required int avatarSeed,
  }) async {
    _profile = await _profileService.saveProfile(
      username: username,
      avatarSeed: avatarSeed,
    );
    notifyListeners();
  }

  Future<void> trustFastId(String payload) async {
    final remoteProfile = UserProfile.fromFastIdPayload(payload);
    _trustedDevices = await _profileService.trustProfile(remoteProfile);
    notifyListeners();
  }
}

