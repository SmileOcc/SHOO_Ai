#!/usr/bin/env bash
# 幂等：配置 core.hooksPath、安装 .git/hooks 引导脚本、赋予可执行权限。
# 由 git pull（post-merge）、切换分支（post-checkout）、打开 IDE 时自动调用。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

QUIET=0
if [[ "${1:-}" == "--quiet" ]]; then
  QUIET=1
fi

log() {
  if [[ "$QUIET" -eq 0 ]]; then
    echo "$@"
  fi
}

# 1) 通过 include 加载仓库内 .gitconfig.hooks（hooksPath = .githooks）
if [[ -f "$ROOT/.gitconfig.hooks" ]]; then
  CURRENT_INCLUDE="$(git config --local --get-all include.path 2>/dev/null || true)"
  if ! printf '%s\n' "$CURRENT_INCLUDE" | grep -qx '../.gitconfig.hooks'; then
    git config --local --add include.path '../.gitconfig.hooks'
    log "已写入 git config include.path → .gitconfig.hooks"
  fi
else
  git config core.hooksPath .githooks
fi

# 2) 确保 .githooks 与 CI 脚本可执行
chmod +x "$ROOT/scripts/ci_check.sh" 2>/dev/null || true
for hook in "$ROOT"/.githooks/*; do
  [[ -f "$hook" ]] && chmod +x "$hook"
done

# 3) 安装引导 hook 到 .git/hooks（clone 后首次 pull 也能触发 ensure）
GIT_DIR="$(git rev-parse --git-dir)"
BOOTSTRAP_SRC="$ROOT/scripts/bootstrap"
mkdir -p "$GIT_DIR/hooks"

install_bootstrap() {
  local name=$1
  if [[ -f "$BOOTSTRAP_SRC/$name" ]]; then
    cp "$BOOTSTRAP_SRC/$name" "$GIT_DIR/hooks/$name"
    chmod +x "$GIT_DIR/hooks/$name"
  fi
}

install_bootstrap post-merge
install_bootstrap post-checkout

log "Git hooks 已就绪（core.hooksPath=.githooks）"
log "  pull / checkout 后自动维护；合并或 push 到 main/master/dev 时运行 CI 检查"
