#!/data/data/com.termux/files/usr/bin/bash
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
T="$HOME/.termux"
B="$HOME/.dark-backup"
mkdir -p "$T" "$B"

for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$T/colors.properties" "$T/termux.properties"; do
  if [[ -f "$f" ]]; then
    cp -n "$f" "$B/$(basename "$f").bak" 2>/dev/null || true
  fi
done

mkdir -p \
  "$HOME/.darkhost" \
  "$HOME/.darkhost/config" \
  "$HOME/.darkhost/logs" \
  "$HOME/.darkhost/vault" \
  "$HOME/.darkhost/history" \
  "$HOME/.darkhost/sessions" \
  "$HOME/.darkhost/themes" \
  "$HOME/.darkhost/plugins" \
  "$HOME/.darkhost/profiles" \
  "$HOME/.darkhost/backups"

cp "$ROOT/bashrc" "$HOME/.bashrc"
cp "$ROOT/bash_profile" "$HOME/.bash_profile"
cp "$ROOT/profile" "$HOME/.profile"
cp "$ROOT/colors.properties" "$T/colors.properties"
cp "$ROOT/termux.properties" "$T/termux.properties"
cp "$ROOT/darkhost.sh" "$HOME/.darkhost/darkhost.sh"
chmod +x "$HOME/.darkhost/darkhost.sh"

if [[ ! -f "$HOME/.darkhost/config/darkhost.conf" ]]; then
  cat > "$HOME/.darkhost/config/darkhost.conf" <<'EOF'
DARKHOST_USERNAME="dark"
DARKHOST_PASSWORD="darkhost"
DARKHOST_THEME="black"
DARKHOST_LABEL="dark"
DARKHOST_BANNER=1
DARKHOST_STARTUP=1
DARKHOST_HACKER=0
DARKHOST_LOGIN_MODE="secure"
DARKHOST_ANIMATIONS=1
DARKHOST_MODE="normal"
EOF
fi
printf '%s\n' "dark" > "$HOME/.darkhost/username" 2>/dev/null || true
printf '%s\n' "darkhost" > "$HOME/.darkhost/password" 2>/dev/null || true

touch "$HOME/.hushlogin"
termux-reload-settings 2>/dev/null || true

cat > "$HOME/.bashrc" <<'EOF'
# Dark Host bootstrap
if [[ -f "$HOME/.darkhost/darkhost.sh" ]]; then
  . "$HOME/.darkhost/darkhost.sh"
fi

# Preserve normal shell aliases/functions from the repo defaults.
export DARK_TERMUX=1
alias c='clear'
alias cl='clear'
alias cls='clear'
alias l='ls -CF'
alias ll='ls -lah'
alias la='ls -A'
alias lt='ls -lahtr'
alias dfh='df -h'
alias duh='du -h'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='history'
alias g='git'
alias glog='git log --oneline --decorate --graph -15'
alias reload='source ~/.bashrc'

mkcd() {
  if [[ $# -ne 1 ]]; then
    printf 'Usage: mkcd <directory>\n' >&2
    return 2
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

if [[ -f "$HOME/.darkrc" ]]; then
  source "$HOME/.darkrc"
fi
EOF

printf '\033c'
printf '\033[1;32m'
cat <<'EOF'
╔══════════════════════════════════════╗
║          D A R K   H O S T          ║
║         S E C U R E   C O R E      ║
╠══════════════════════════════════════╣
║  STATUS : ONLINE                   ║
║  MODE   : CUSTOM SHELL             ║
║  ACCESS : SECURE TERMINAL          ║
╚══════════════════════════════════════╝
EOF
printf '\033[0m'
echo
echo "[✓] Dark Host shell installed permanently."
echo "[✓] Bash bootstrap configured."
echo "[✓] Persistent config folder: ~/.darkhost"
echo "[✓] Default login: dark / darkhost"
echo "[✓] Restart Termux to begin."
