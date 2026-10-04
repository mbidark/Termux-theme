#!/data/data/com.termux/files/usr/bin/bash
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
DARKHOST_VERSION="$(tr -d '\r\n' < "$ROOT/VERSION")"
T="$HOME/.termux"
B="$HOME/.dark-backup"
CONFIG_FILE="$HOME/.darkhost/config/darkhost.conf"
is_upgrade=0
[[ -f "$HOME/.darkhost/darkhost.sh" ]] && is_upgrade=1

__darkhost_setup_wizard() {
  if [[ ! -t 0 ]]; then
    cat > "$CONFIG_FILE" <<EOF
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
DARKHOST_VERSION="$DARKHOST_VERSION"
EOF
    printf '%s\n' "dark" > "$HOME/.darkhost/username" 2>/dev/null || true
    printf '%s\n' "darkhost" > "$HOME/.darkhost/password" 2>/dev/null || true
    return 0
  fi

  printf '\nDARK HOST SETUP\n'
  printf 'Create your local terminal identity.\n\n'
  read -p 'Username [dark]: ' username
  username="${username:-dark}"
  read -s -p 'Password [darkhost]: ' password
  printf '\n'
  password="${password:-darkhost}"
  read -p 'Theme [black/blood/matrix/ghost/void/cyber/terminal] [black]: ' theme
  theme="${theme:-black}"
  read -p 'Prompt label [dark]: ' label
  label="${label:-dark}"
  read -p 'Mode [normal/hacker/ghost/matrix/forensic/void/minimal] [normal]: ' mode
  mode="${mode:-normal}"
  read -p 'Startup banner [1/0] [1]: ' banner
  banner="${banner:-1}"
  if [[ ! "$banner" =~ ^[01]$ ]]; then banner=1; fi
  read -p 'Animations [1/0] [1]: ' animations
  animations="${animations:-1}"
  if [[ ! "$animations" =~ ^[01]$ ]]; then animations=1; fi

  cat > "$CONFIG_FILE" <<EOF
DARKHOST_USERNAME="${username}"
DARKHOST_PASSWORD="${password}"
DARKHOST_THEME="${theme}"
DARKHOST_LABEL="${label}"
DARKHOST_BANNER=${banner}
DARKHOST_STARTUP=1
DARKHOST_HACKER=0
DARKHOST_LOGIN_MODE="secure"
DARKHOST_ANIMATIONS=${animations}
DARKHOST_MODE="${mode}"
DARKHOST_VERSION="$DARKHOST_VERSION"
EOF

  printf '%s\n' "$username" > "$HOME/.darkhost/username" 2>/dev/null || true
  printf '%s\n' "$password" > "$HOME/.darkhost/password" 2>/dev/null || true
  printf '\nProfile saved.\n'
  printf 'Username: %s\n' "$username"
  printf 'Theme: %s\n' "$theme"
  printf 'Mode: %s\n' "$mode"
}

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
  "$HOME/.darkhost/backups" \
  "$HOME/.darkhost/servers"

if (( is_upgrade == 0 )); then
  cp "$ROOT/bashrc" "$HOME/.bashrc"
  cp "$ROOT/bash_profile" "$HOME/.bash_profile"
  cp "$ROOT/profile" "$HOME/.profile"
  cp "$ROOT/colors.properties" "$T/colors.properties"
  cp "$ROOT/termux.properties" "$T/termux.properties"
fi
cp "$ROOT/darkhost.sh" "$HOME/.darkhost/darkhost.sh"
cp "$ROOT/VERSION" "$HOME/.darkhost/VERSION"
chmod +x "$HOME/.darkhost/darkhost.sh"

if [[ ! -f "$CONFIG_FILE" ]]; then
  __darkhost_setup_wizard
else
  if [[ -t 0 && "${DARKHOST_UPDATE:-0}" != 1 ]]; then
    printf '\nDark Host profile already exists.\n'
    read -p 'Reconfigure now? [Y/n]: ' reconfigure
    if [[ -z "$reconfigure" || "$reconfigure" =~ ^[Yy]$ ]]; then
      __darkhost_setup_wizard
    fi
  fi
fi

printf '%s\n' "$(grep '^DARKHOST_USERNAME=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"' || printf 'dark')" > "$HOME/.darkhost/username" 2>/dev/null || true
printf '%s\n' "$(grep '^DARKHOST_PASSWORD=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"' || printf 'darkhost')" > "$HOME/.darkhost/password" 2>/dev/null || true

touch "$HOME/.hushlogin"
termux-reload-settings 2>/dev/null || true

if (( is_upgrade == 0 )); then
  cat > "$HOME/.bashrc" <<'EOF'
# Dark Host bootstrap
if [[ -f "$HOME/.darkhost/darkhost.sh" ]]; then
  . "$HOME/.darkhost/darkhost.sh"
fi

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
fi

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  printf '\033[38;5;46m'
fi
cat <<'EOF'
╔══════════════════════════════════════╗
║          D A R K   H O S T          ║
║         T E R M I N A L  S H E L L   ║
╠══════════════════════════════════════╣
║  STATUS : INSTALLED                ║
║  SHELL  : BASH BOOTSTRAP            ║
║  PROFILE: LOCAL CONFIGURATION       ║
╚══════════════════════════════════════╝
EOF
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  printf '\033[0m'
fi
echo
echo "[✓] Dark Host shell installed permanently."
echo "[✓] Bash bootstrap configured."
echo "[✓] Persistent config folder: ~/.darkhost"
echo "[✓] Restart Termux to begin."
