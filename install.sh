#!/data/data/com.termux/files/usr/bin/bash
set -e

TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"
ROOT="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$TERMUX_DIR" "$BACKUP_DIR"

echo
printf '\033[1;32m'
echo '╔══════════════════════════════════╗'
echo '║        D A R K   H O S T         ║'
echo '║       TERMUX HACKER THEME        ║'
echo '╚══════════════════════════════════╝'
printf '\033[0m'
echo

backup() {
    [ -f "$1" ] && cp "$1" "$BACKUP_DIR/$(basename "$1").bak"
}

backup "$HOME/.bashrc"
backup "$TERMUX_DIR/colors.properties"
backup "$TERMUX_DIR/termux.properties"

cp "$ROOT/colors.properties" "$TERMUX_DIR/colors.properties"
cp "$ROOT/termux.properties" "$TERMUX_DIR/termux.properties"
cp "$ROOT/bashrc" "$HOME/.bashrc"

termux-reload-settings 2>/dev/null || true

echo
printf '\033[1;32m[✓] DARK HOST Hacker Theme installed.\033[0m\n'
printf '\033[1;32m[✓] Extra-key bar hidden.\033[0m\n'
printf '\033[1;32m[✓] Backup: %s\033[0m\n' "$BACKUP_DIR"
echo
echo "Restart Termux or run: source ~/.bashrc"
