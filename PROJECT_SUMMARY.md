# Fast Share Pro Project Proposal

## Executive Summary

Fast Share Pro is a high-performance local sharing suite built in Flutter with Clean Architecture. It combines Wi-Fi Direct style nearby discovery, local socket streaming, QR pairing, trusted device identity, group sharing, PC Web Drop, secure storage, offline chat, and smart storage tools in one true-black OLED-first interface.

The product is designed for users who want fast local transfer without cloud upload, accounts, compression by messaging apps, or unreliable cable workflows. The Pro edition adds privacy and workflow features that make Fast Share useful not only for one-off transfers, but also for device migration, group sharing, PC exchange, field teams, classrooms, studios, and families.

## Product Identity and Onboarding

On first launch, Fast Share Pro creates a local user profile with username and avatar. The username becomes the Nearby Connections endpoint name, making device discovery human-readable instead of generic. Each profile also generates a Fast ID QR code. Scanning another user's Fast ID saves that device as trusted, enabling paired workflows such as clipboard sync, scheduled transfers, and future silent approvals.

The permission guard explains storage, location, camera, and nearby discovery needs before system prompts. This keeps onboarding transparent: camera is used for QR pairing, location and nearby radios support discovery, and storage access enables large file selection and downloads.

## Secure Vault and Encryption

Fast Share Pro includes a Secure Vault for sensitive files. The implementation uses password-derived SHA-256 key material from the `crypto` package and AES-GCM encryption from `cryptography`, because the Dart `crypto` package provides hashing and HMAC but not AES primitives.

Vault files are written as a Fast Share vault format with encrypted chunks, per-chunk nonces, and authentication tags. This design avoids loading large files into memory and keeps the vault compatible with multi-gigabyte content. Decryption requires the original password and verifies every encrypted chunk before writing the output.

## Radar and Gesture-Based UI

The Radar screen presents nearby discovery as a rotating neon scanner using the app's Electric Blue and Magenta identity. Users can start discovery, advertise their device, toggle Incognito Mode, and enable Shake to Share. Incognito Mode stops discovery and advertising so the device disappears from nearby radars.

Gesture Share is built into the sender flow: selected files can be thrown into a session with a swipe-up gesture. This makes sharing feel immediate while preserving the regular button-based workflow for accessibility and predictability.

## Group Sharing and PC Web Drop

The socket transfer protocol now supports up to four simultaneous receiver sockets from one host session. The sender broadcasts/discovers with `nearby_connections`, then streams the actual file data over local sockets for predictable performance. Every file stream is chunked at 64KB, which keeps memory stable for 4GB+ files.

Auto-resume is implemented through a manifest and resume-offset handshake. The sender first transmits file metadata, the receiver responds with current partial byte offsets, and the sender resumes each file from the last written chunk.

PC Web Drop turns the phone into a local HTTP server. Computers on the same Wi-Fi can download selected mobile files from the browser and upload files back to the phone through a multipart Web Drop form. Uploaded files are saved to the Fast Share Web Drop folder.

## Advanced Feature Pack

Fast Share Pro includes:

- Offline Chat for text and links during active transfer sessions.
- Clipboard Sync for trusted devices with explicit user-controlled toggling.
- Instant Compression using `archive` to create ZIP files from selected files.
- Live Preview metadata through transfer manifests before streamed data begins.
- Remote Camera handoff service for preview initialization and future frame relaying to trusted receivers.
- Scheduled Transfer queues for sending selected files automatically when a trusted device appears nearby.
- Silent Transfer groundwork through persistent local transfer notifications.
- Smart Cleanup suggestions for large files, installers, archives, and likely duplicates after successful transfer.

## Technical Architecture

The codebase follows Clean Architecture:

- `lib/domain`: entities, enums, transfer metadata, profile models, trusted devices, vault records, scheduled transfers, and chat messages.
- `lib/data`: services for profile persistence, permissions, Nearby Connections, socket streaming, PC HTTP serving, vault encryption, chat framing, clipboard sync, shake detection, compression, notifications, camera preview, and scheduled transfer storage.
- `lib/presentation`: Provider controllers, screens, reusable widgets, radar painter, dashboard, onboarding, profile, transfer, PC, vault, chat, tools, cleanup, and settings UI.

State management uses Provider and ChangeNotifier. Local persistence uses `shared_preferences`. The app supports English and Arabic with RTL/LTR switching and dark/light themes, with true black as the primary dark-mode background.

## Developer Guide

Install Flutter, then run:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

If platform files need regeneration:

```bash
flutter create --platforms=android --project-name fast_share .
```

Primary implementation files:

- Profile: `lib/data/services/profile_service.dart`
- Resume/group transfer: `lib/data/services/socket_transfer_service.dart`
- PC Web Drop: `lib/data/services/pc_http_server_service.dart`
- Secure Vault: `lib/data/services/vault_service.dart`
- Radar/shake: `lib/presentation/screens/radar_screen.dart`
- Tools hub: `lib/presentation/screens/pro_tools_screen.dart`

## Technical Roadmap

1. Add persistent vault index storage and biometric unlock.
2. Bind Offline Chat, Clipboard Sync, and Remote Camera frames to live Nearby payload endpoints.
3. Add foreground service isolates for long-running silent transfers on Android.
4. Add receiver-side accept/reject screen using the preview manifest.
5. Add per-peer transfer dashboards for group sessions.
6. Harden resume metadata with checksums per chunk.
7. Add desktop companion and LAN discovery via mDNS.
8. Add integration tests on physical Android devices for Nearby, sockets, camera, and large-file resume.
