#!/usr/bin/env bash
# 受 CI 保护的分支（与 .github/workflows/ci.yml 保持一致）。
CI_PROTECTED_BRANCHES=(main master dev)

ci_is_protected_branch() {
  local branch=$1
  local item
  for item in "${CI_PROTECTED_BRANCHES[@]}"; do
    if [[ "$branch" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

ci_protected_branch_from_remote_ref() {
  local ref=$1
  local item
  for item in "${CI_PROTECTED_BRANCHES[@]}"; do
    if [[ "$ref" == "refs/heads/$item" ]]; then
      echo "$item"
      return 0
    fi
  done
  return 1
}
