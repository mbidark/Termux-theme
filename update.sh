#!/data/data/com.termux/files/usr/bin/bash
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Update must be run from a Dark Host Git checkout.\n' >&2
  exit 1
fi
git pull --ff-only
chmod +x ./*.sh 2>/dev/null || true
DARKHOST_UPDATE=1 bash ./install.sh
