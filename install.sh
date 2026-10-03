#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"

mkdir -p "$TERMUX_DIR" "$BACKUP_DIR"

echo "╭──────────────────────────────╮"
echo "│        D A R K   H O S T     │"
echo "│       Termux Theme Setup     │"
echo "╰──────────────────────────────╯"
echo

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$(basename "$file").bak"
        echo "[+] Backup: $file"
    fi
}

backup_file "$HOME/.bashrc"
backup_file "$TERMUX_DIR/colors.properties"
backup_file "$TERMUX_DIR/termux.properties"

cp "$ROOT/config/bashrc" "$HOME/.bashrc"
cp "$ROOT/config/colors.properties" "$TERMUX_DIR/colors.properties"
cp "$ROOT/config/termux.properties" "$TERMUX_DIR/termux.properties"

echo "[+] DARK HOST theme installed."
echo "[+] Extra-key bar hidden."
echo "[+] Backups saved to: $BACKUP_DIR"
echo

if command -v termux-reload-settings >/dev/null 2>&1; then
    termux-reload-settings
    echo "[+] Termux settings reloaded."
fi

echo
echo "Restart Termux or run: source ~/.bashrc"
echo "Uninstall with: ./uninstall.sh"
