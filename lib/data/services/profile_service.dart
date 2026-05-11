import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/trusted_device.dart';
import '../../domain/entities/user_profile.dart';

class ProfileService {
  const ProfileService(this._preferences);

  final SharedPreferences _preferences;

  UserProfile? loadProfile() {
    final raw = _preferences.getString(AppConstants.profileKey);
    if (raw == null) {
      return null;
    }
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<UserProfile> saveProfile({
    required String username,
    required int avatarSeed,
  }) async {
    final existing = loadProfile();
    final profile = UserProfile(
      id: existing?.id ?? _newProfileId(username),
      username: username.trim(),
      avatarSeed: avatarSeed,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _preferences.setString(
      AppConstants.profileKey,
      jsonEncode(profile.toJson()),
    );
    return profile;
  }

  List<TrustedDevice> loadTrustedDevices() {
    final raw = _preferences.getString(AppConstants.trustedDevicesKey);
    if (raw == null) {
      return const [];
    }
    final list = jsonDecode(raw) as List<Object?>;
    return list
        .cast<Map<String, Object?>>()
        .map(TrustedDevice.fromJson)
        .toList();
  }

  Future<List<TrustedDevice>> trustProfile(UserProfile profile) async {
    final devices = loadTrustedDevices();
    final trusted = TrustedDevice(
      id: profile.id,
      username: profile.username,
      avatarSeed: profile.avatarSeed,
      pairedAt: DateTime.now(),
    );
    final updated = [
      trusted,
      ...devices.where((device) => device.id != profile.id),
    ];
    await _preferences.setString(
      AppConstants.trustedDevicesKey,
      jsonEncode(updated.map((device) => device.toJson()).toList()),
    );
    return updated;
  }

  String _newProfileId(String username) {
    final random = Random.secure();
    final nonce = List<int>.generate(24, (_) => random.nextInt(256));
    final seed = utf8.encode('$username:${DateTime.now().microsecondsSinceEpoch}');
    return sha256.convert([...seed, ...nonce]).toString();
  }
}

