#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
T="$HOME/.termux"
B="$HOME/.dark-backup"
mkdir -p "$T" "$B"
for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$T/colors.properties" "$T/termux.properties"; do
  [ -f "$f" ] && cp -n "$f" "$B/$(basename "$f").bak" 2>/dev/null || true
done
cp "$ROOT/bashrc" "$HOME/.bashrc"
cp "$ROOT/bash_profile" "$HOME/.bash_profile"
cp "$ROOT/profile" "$HOME/.profile"
cp "$ROOT/colors.properties" "$T/colors.properties"
cp "$ROOT/termux.properties" "$T/termux.properties"
touch "$HOME/.hushlogin"
termux-reload-settings 2>/dev/null || true
printf '\033c'
printf '\033[1;32m'
cat <<'EOF'
╔══════════════════════════════════════╗
║          D A R K   T E R M U X       ║
║       H A C K E R   M O D E          ║
╠══════════════════════════════════════╣
║  STATUS : ONLINE                     ║
║  MODE   : DARK                        ║
║  ACCESS : TERMINAL                   ║
╚══════════════════════════════════════╝
EOF
printf '\033[0m'
echo
echo "[✓] DARK theme installed permanently."
echo "[✓] Termux welcome text hidden."
echo "[✓] Extra keys hidden."
echo "[✓] Restart Termux."
