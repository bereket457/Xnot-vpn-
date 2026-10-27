# Xnot VPN

A Flutter Android VPN client using the WireGuard Android tunnel library.

## Build

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Requirements:

- Flutter 3.22+
- Android Studio
- Android SDK 35
- JDK 17
- Android API 24+

See `BUILD_AND_NEXT_STEPS.md` and `WIREGUARD_SETUP.md`.

## Real VPN traffic

The app uses the WireGuard `GoBackend` on Android. It still requires a real WireGuard server and valid client configuration.

The app is intended for servers you own or are authorized to use.

## Security

The client stores a WireGuard private key locally because it is required to establish the tunnel. Do not share the key or include a server private key in the app.

No payload injection, SNI spoofing, telecom restriction bypass, or carrier-policy evasion is included.
