#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [ ! -d .git ]; then
    echo "[!] Git repository not found."
    exit 1
fi

echo "[+] Updating DARK HOST..."
git pull --ff-only

chmod +x install.sh update.sh uninstall.sh
./install.sh

echo "[✓] DARK HOST updated."
