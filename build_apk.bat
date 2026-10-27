@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter SDK is not installed or not on PATH.
  exit /b 1
)
flutter pub get
if errorlevel 1 exit /b 1
flutter analyze
if errorlevel 1 exit /b 1
flutter build apk --release
if errorlevel 1 exit /b 1
echo.
echo APK: build\app\outputs\flutter-apk\app-release.apk
