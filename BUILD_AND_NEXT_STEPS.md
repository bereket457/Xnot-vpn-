# Xnot VPN — APK Build & Install

## Requirements

- Flutter SDK 3.22+ (a recent stable Flutter release is recommended)
- Android Studio
- Android SDK Platform 35
- Android SDK Build-Tools
- JDK 17
- An Android phone/emulator with Android 7.0+ (API 24+)

## 1. Open the project

Open the `Xnot_VPN_Final` folder in Android Studio or VS Code.

Do not open only the `android` subfolder when using Flutter.

## 2. Configure Flutter

From the project root:

```bash
flutter doctor
flutter pub get
```

If Android Studio asks for the Flutter SDK, select your Flutter SDK directory.

For command-line Android builds, create:

`android/local.properties`

Example:

```properties
flutter.sdk=/path/to/flutter
sdk.dir=/path/to/Android/Sdk
```

On Windows, use paths such as:

```properties
flutter.sdk=C:\\src\\flutter
sdk.dir=C:\\Users\\YOUR_NAME\\AppData\\Local\\Android\\Sdk
```

## 3. Check the project

```bash
flutter analyze
```

## 4. Build the release APK

```bash
flutter build apk --release
```

Output:

`build/app/outputs/flutter-apk/app-release.apk`

Or use:

- Linux/macOS: `./build_apk.sh`
- Windows: `build_apk.bat`

## 5. Install on a phone

Enable Developer Options and USB debugging, connect the phone, then:

```bash
flutter devices
flutter install
```

Or install the generated APK manually:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## 6. Configure Xnot VPN

Inside the app open:

**Settings → WireGuard Configuration**

Enter the client values from a WireGuard server you own or are authorized to use:

- Client private key
- Client address
- Server peer public key
- Server endpoint (`host:port`)
- Allowed IPs
- Optional persistent keepalive

Then save and tap **Connect**.

## Important

This is a WireGuard VPN client. It does not create a VPN server by itself.

Real traffic requires a reachable, correctly configured WireGuard server.

Do not put the server's private key in the Android app.

This project does not implement payload injection, SNI spoofing, traffic obfuscation, or telecom/network-policy bypass.
