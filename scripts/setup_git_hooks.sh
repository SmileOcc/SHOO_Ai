#!/usr/bin/env bash
# 兼容旧命令；等价于 ensure_git_hooks.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$ROOT/scripts/ensure_git_hooks.sh" "$@"
