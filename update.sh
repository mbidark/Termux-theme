#!/data/data/com.termux/files/usr/bin/bash
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git fetch --all --prune 2>/dev/null || true
  git reset --hard HEAD >/dev/null 2>&1 || true
fi
chmod +x ./*.sh 2>/dev/null || true
./install.sh
