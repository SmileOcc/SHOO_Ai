#!/usr/bin/env bash
# 为本仓库启用 .githooks（合并 / push 到 main、master 时本地跑 CI）。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod +x scripts/ci_check.sh .githooks/pre-commit .githooks/pre-merge-commit .githooks/pre-push
git config core.hooksPath .githooks

echo "已启用 Git hooks：core.hooksPath=.githooks"
echo "  - 在 main/master 上 commit / merge 前会运行 scripts/ci_check.sh"
echo "  - push 到 origin main/master 前会运行 scripts/ci_check.sh"
echo "跳过检查：git commit|merge|push --no-verify"
