#!/usr/bin/env bash
set -euo pipefail

: "${CROPSENSE_API_URL:=http://127.0.0.1:8000}"
: "${APP_VERSION:=1.0.0}"

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

flutter --version
flutter pub get
flutter build web --release --dart-define=CROPSENSE_API_URL=$CROPSENSE_API_URL --dart-define=APP_VERSION=$APP_VERSION
