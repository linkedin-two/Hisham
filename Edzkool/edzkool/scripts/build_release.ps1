# Production release build (run from edzkool/)
# Requires: flutter SDK, production API URL, release keystore (android/key.properties)

# Generate cert pin for your API host:
# openssl s_client -connect YOUR_HOST:443 -servername YOUR_HOST </dev/null 2>/dev/null | openssl x509 -outform der | openssl dgst -sha256 -binary | openssl enc -base64

$apiUrl = "https://edvoyage-backup-cursor-2.onrender.com"
$certPin = $env:API_CERT_SHA256  # Set before running, or leave empty to skip pinning

$dartDefines = @(
    "APP_ENV=production",
    "API_BASE_URL=$apiUrl"
)
if ($certPin) {
    $dartDefines += "API_CERT_SHA256=$certPin"
}

$defineArgs = $dartDefines | ForEach-Object { "--dart-define=$_" }

flutter pub get
# Build Android App Bundle (.aab) for Google Play Store
flutter build appbundle --release @defineArgs `
  --obfuscate `
  --split-debug-info=build/symbols/android

# Build standalone release APK for direct testing
flutter build apk --release @defineArgs `
  --obfuscate `
  --split-debug-info=build/symbols/android

flutter build web --release @defineArgs `
  --obfuscate `
  --split-debug-info=build/symbols/web
