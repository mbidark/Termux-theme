#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
git fetch origin
git reset --hard origin/main
git clean -fd
chmod +x *.sh
./install.sh
