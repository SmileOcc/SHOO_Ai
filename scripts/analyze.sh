#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart analyze lib test
flutter test
