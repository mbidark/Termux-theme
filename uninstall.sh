#!/data/data/com.termux/files/usr/bin/bash
set -e

TERMUX_DIR="$HOME/.termux"
BACKUP_DIR="$HOME/.dark-host-backup"

echo "Removing DARK HOST theme..."

if [ -f "$BACKUP_DIR/bashrc.bak" ]; then
    cp "$BACKUP_DIR/bashrc.bak" "$HOME/.bashrc"
else
    rm -f "$HOME/.bashrc"
fi

if [ -f "$BACKUP_DIR/colors.properties.bak" ]; then
    cp "$BACKUP_DIR/colors.properties.bak" "$TERMUX_DIR/colors.properties"
else
    rm -f "$TERMUX_DIR/colors.properties"
fi

if [ -f "$BACKUP_DIR/termux.properties.bak" ]; then
    cp "$BACKUP_DIR/termux.properties.bak" "$TERMUX_DIR/termux.properties"
else
    rm -f "$TERMUX_DIR/termux.properties"
fi

if command -v termux-reload-settings >/dev/null 2>&1; then
    termux-reload-settings
fi

echo "[+] DARK HOST theme removed."
echo "[+] Your previous configuration was restored when a backup existed."
