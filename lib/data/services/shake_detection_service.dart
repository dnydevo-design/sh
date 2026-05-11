import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectionService {
  StreamSubscription<AccelerometerEvent>? _subscription;

  void start({required VoidCallback onShake}) {
    DateTime lastShake = DateTime.fromMillisecondsSinceEpoch(0);
    _subscription?.cancel();
    _subscription = accelerometerEvents.listen(
      (event) {
        final force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        final now = DateTime.now();
        if (force > 23 && now.difference(lastShake).inMilliseconds > 900) {
          lastShake = now;
          onShake();
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

typedef VoidCallback = void Function();

