#!/usr/bin/env bash
# 与 .github/workflows/ci.yml 保持一致的本机 CI 检查。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "错误：未找到 flutter，请先安装 Flutter 并加入 PATH。" >&2
  exit 1
fi

echo "→ flutter pub get"
flutter pub get

echo "→ dart format --output=none --set-exit-if-changed ."
dart format --output=none --set-exit-if-changed .

echo "→ flutter analyze --fatal-warnings --no-fatal-infos"
flutter analyze --fatal-warnings --no-fatal-infos

echo "→ flutter test"
flutter test

echo "✅ 全部 CI 检查通过"
