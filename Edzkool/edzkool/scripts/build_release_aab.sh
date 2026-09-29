#!/bin/bash
set -e

# Production release AAB build for Google Play Store (run from edzkool/)
API_URL="https://edvoyage-backup-cursor-2.onrender.com"
DART_DEFINES=(
  "--dart-define=APP_ENV=production"
  "--dart-define=API_BASE_URL=${API_URL}"
)

if [ -n "$API_CERT_SHA256" ]; then
  DART_DEFINES+=("--dart-define=API_CERT_SHA256=${API_CERT_SHA256}")
fi

echo "==> Running flutter clean & pub get..."
flutter clean
flutter pub get

echo "==> Building Release App Bundle (.aab) for Google Play..."
flutter build appbundle --release "${DART_DEFINES[@]}" \
  --obfuscate \
  --split-debug-info=build/symbols/android

echo "==> Release AAB built successfully!"
echo "Location: build/app/outputs/bundle/release/app-release.aab"
