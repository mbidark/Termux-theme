#!/data/data/com.termux/files/usr/bin/bash
set -e
T="$HOME/.termux"; B="$HOME/.dark-backup"
restore(){ [ -f "$B/$(basename "$1").bak" ] && cp "$B/$(basename "$1").bak" "$1"; }
restore "$HOME/.bashrc"; restore "$HOME/.bash_profile"; restore "$HOME/.profile"
restore "$T/colors.properties"; restore "$T/termux.properties"
rm -f "$HOME/.hushlogin"
termux-reload-settings 2>/dev/null || true
echo "[✓] DARK theme removed."
