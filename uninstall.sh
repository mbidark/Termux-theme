#!/data/data/com.termux/files/usr/bin/bash
set -e

TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"

echo "[+] Removing DARK HOST theme..."

if [ -f "$BACKUP_DIR/bashrc.bak" ]; then
    cp "$BACKUP_DIR/bashrc.bak" "$HOME/.bashrc"
fi

if [ -f "$BACKUP_DIR/colors.properties.bak" ]; then
    cp "$BACKUP_DIR/colors.properties.bak" "$TERMUX_DIR/colors.properties"
fi

if [ -f "$BACKUP_DIR/termux.properties.bak" ]; then
    cp "$BACKUP_DIR/termux.properties.bak" "$TERMUX_DIR/termux.properties"
fi

termux-reload-settings 2>/dev/null || true

echo "[✓] DARK HOST removed."
