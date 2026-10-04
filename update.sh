#!/data/data/com.termux/files/usr/bin/bash
set -eu
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Update must be run from a Dark Host Git checkout.\n' >&2
  exit 1
fi
remote_branch="$(git ls-remote --symref origin HEAD 2>/dev/null | awk '$1 == "ref:" && $3 == "HEAD" {sub("refs/heads/", "", $2); print $2; exit}')"
if [[ -z "$remote_branch" ]]; then
  remote_branch="$(git branch --show-current)"
fi
if [[ -z "$remote_branch" ]]; then
  printf 'Cannot determine the origin default branch from a detached checkout.\n' >&2
  exit 1
fi
git pull --ff-only origin "$remote_branch"
chmod +x ./*.sh 2>/dev/null || true
DARKHOST_UPDATE=1 bash ./install.sh
