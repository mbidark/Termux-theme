#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo
printf '\033[1;32m[+] Checking GitHub updates...\033[0m\n'

if [ ! -d "$ROOT/.git" ]; then
    echo "[!] This directory is not a Git repository."
    echo "[!] Clone it first:"
    echo "    git clone https://github.com/mbidark/Termux-theme.git"
    exit 1
fi

cd "$ROOT"

git pull --ff-only

echo
printf '\033[1;32m[+] Applying latest theme...\033[0m\n'
chmod +x install.sh update.sh uninstall.sh
./install.sh

echo
printf '\033[1;32m[✓] DARK HOST updated successfully.\033[0m\n'
