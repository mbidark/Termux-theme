#!/data/data/com.termux/files/usr/bin/bash
set -eu

T="$HOME/.termux"
B="$HOME/.dark-backup"
restore(){
  local target="$1"
  local backup="$B/$(basename "$target").bak"
  if [[ -f "$backup" ]]; then
    cp "$backup" "$target"
  else
    rm -f "$target"
  fi
}
restore "$HOME/.bashrc"
restore "$HOME/.bash_profile"
restore "$HOME/.profile"
restore "$T/colors.properties"
restore "$T/termux.properties"
rm -rf "$HOME/.darkhost"
rm -f "$HOME/.hushlogin"
termux-reload-settings 2>/dev/null || true
echo "[✓] Dark Host layer removed."
