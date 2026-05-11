import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/entities/transfer_file.dart';
import '../../domain/entities/trusted_device.dart';

class ScheduledTransferService {
  const ScheduledTransferService(this._preferences);

  final SharedPreferences _preferences;

  List<ScheduledTransfer> load() {
    final raw = _preferences.getString(AppConstants.scheduledTransfersKey);
    if (raw == null) {
      return const [];
    }
    final list = jsonDecode(raw) as List<Object?>;
    return list
        .cast<Map<String, Object?>>()
        .map(ScheduledTransfer.fromJson)
        .toList();
  }

  Future<List<ScheduledTransfer>> queue({
    required TrustedDevice device,
    required List<TransferFile> files,
  }) async {
    final current = load();
    final id = sha1
        .convert(utf8.encode('${device.id}:${DateTime.now().microsecondsSinceEpoch}'))
        .toString();
    final transfer = ScheduledTransfer(
      id: id,
      deviceId: device.id,
      deviceName: device.username,
      fileIds: files.map((file) => file.id).toList(),
      createdAt: DateTime.now(),
    );
    final updated = [transfer, ...current];
    await _save(updated);
    return updated;
  }

  Future<List<ScheduledTransfer>> remove(String id) async {
    final updated = load().where((transfer) => transfer.id != id).toList();
    await _save(updated);
    return updated;
  }

  Future<void> _save(List<ScheduledTransfer> transfers) {
    return _preferences.setString(
      AppConstants.scheduledTransfersKey,
      jsonEncode(transfers.map((transfer) => transfer.toJson()).toList()),
    );
  }
}

