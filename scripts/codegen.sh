#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
echo "codegen done"
