#!/data/data/com.termux/files/usr/bin/bash
set -e

TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"

restore() {
    local backup="$BACKUP_DIR/$(basename "$1").bak"
    [ -f "$backup" ] && cp "$backup" "$1"
}

restore "$HOME/.bashrc"
restore "$HOME/.bash_profile"
restore "$HOME/.profile"
restore "$TERMUX_DIR/colors.properties"
restore "$TERMUX_DIR/termux.properties"

termux-reload-settings 2>/dev/null || true

echo "[✓] DARK HOST removed/restored."
echo "[i] Restart Termux."
