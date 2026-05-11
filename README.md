# Fast Share

Fast Share Pro is a clean Flutter implementation for high-speed local file transfer. It starts with profile creation and a permission guard, supports English and Arabic, uses QR codes for Fast ID pairing and transfer joining, streams files in 64KB chunks over local sockets, supports auto-resume, exposes a PC browser Web Drop server, includes a Secure Vault, and suggests smart cleanup after transfer.

## Quick Start

1. Install Flutter and Android Studio.
2. From this folder, run:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

If the Flutter SDK needs to regenerate platform wrappers, run this first:

```bash
flutter create --platforms=android,ios --project-name fast_share .
```

## Architecture

- `lib/domain`: entities, enums, and pure models.
- `lib/data`: services for permissions, profiles, picking files, socket streaming, Nearby Connections, PC HTTP/Web Drop, vault encryption, chat, compression, scheduled transfers, camera preview, notifications, and smart classification.
- `lib/presentation`: Provider controllers, screens, radar painter, and reusable widgets.
- `assets/icon`: generated Fast Share icon source and launcher PNG.

## Notes

- Android Wi-Fi Direct style discovery is implemented through `nearby_connections`.
- The primary transfer path uses a local socket protocol with manifest and resume headers, then streams files in 64KB chunks so files larger than memory can move safely.
- Android hotspot creation is intentionally represented as a fallback mode because modern Android does not allow ordinary Play Store apps to silently toggle hotspot without OEM/system privileges.
- AES vault encryption uses `crypto` for key derivation and `cryptography` for AES-GCM primitives.
