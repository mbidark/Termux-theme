#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"

mkdir -p "$TERMUX_DIR" "$BACKUP_DIR"

backup() {
    [ -f "$1" ] && [ ! -f "$BACKUP_DIR/$(basename "$1").bak" ] && cp "$1" "$BACKUP_DIR/$(basename "$1").bak"
}

backup "$HOME/.bashrc"
backup "$HOME/.bash_profile"
backup "$HOME/.profile"
backup "$TERMUX_DIR/colors.properties"
backup "$TERMUX_DIR/termux.properties"

cp "$ROOT/bashrc" "$HOME/.bashrc"
cp "$ROOT/bash_profile" "$HOME/.bash_profile"
cp "$ROOT/profile" "$HOME/.profile"
cp "$ROOT/colors.properties" "$TERMUX_DIR/colors.properties"
cp "$ROOT/termux.properties" "$TERMUX_DIR/termux.properties"

chmod 644 "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"
chmod 644 "$TERMUX_DIR/colors.properties" "$TERMUX_DIR/termux.properties"

termux-reload-settings 2>/dev/null || true

echo
printf '\033[1;32m'
echo '╔══════════════════════════════════╗'
echo '║        D A R K   H O S T         ║'
echo '║        INSTALL COMPLETE           ║'
echo '╚══════════════════════════════════╝'
printf '\033[0m'
echo
echo "[✓] Permanent shell startup enabled"
echo "[✓] Hacker colors enabled"
echo "[✓] Extra-key bar hidden"
echo "[✓] Backup: $BACKUP_DIR"
echo
echo "Close and reopen Termux."
