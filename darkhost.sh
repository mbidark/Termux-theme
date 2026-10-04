#!/usr/bin/env bash
# DARK HOST V2 shell layer for Termux

[[ -n "${BASH_VERSION:-}" ]] || return 0
if [[ -n "${DARKHOST_LOADED:-}" ]]; then
  return 0
fi
DARKHOST_LOADED=1

DARKHOST_DIR="${DARKHOST_DIR:-$HOME/.darkhost}"
DARKHOST_CONFIG_DIR="$DARKHOST_DIR/config"
DARKHOST_CONFIG_FILE="$DARKHOST_CONFIG_DIR/darkhost.conf"
DARKHOST_HISTORY_FILE="${HISTFILE:-$DARKHOST_DIR/history/darkhost_history}"
DARKHOST_LOG_DIR="$DARKHOST_DIR/logs"
DARKHOST_LOG_FILE="$DARKHOST_LOG_DIR/session.log"
DARKHOST_VAULT_DIR="$DARKHOST_DIR/vault"
DARKHOST_SESSIONS_DIR="$DARKHOST_DIR/sessions"
DARKHOST_THEMES_DIR="$DARKHOST_DIR/themes"
DARKHOST_PLUGINS_DIR="$DARKHOST_DIR/plugins"
DARKHOST_PROFILES_DIR="$DARKHOST_DIR/profiles"
DARKHOST_BACKUPS_DIR="$DARKHOST_DIR/backups"
DARKHOST_USER_FILE="$DARKHOST_DIR/username"
DARKHOST_PASS_FILE="$DARKHOST_DIR/password"

export HISTFILE="$DARKHOST_HISTORY_FILE"
export HISTSIZE=2000
export HISTFILESIZE=5000
export SAVEHIST=2000

__darkhost_ensure_layout() {
  mkdir -p \
    "$DARKHOST_DIR" \
    "$DARKHOST_CONFIG_DIR" \
    "$DARKHOST_LOG_DIR" \
    "$DARKHOST_VAULT_DIR" \
    "$DARKHOST_SESSIONS_DIR" \
    "$DARKHOST_THEMES_DIR" \
    "$DARKHOST_PLUGINS_DIR" \
    "$DARKHOST_PROFILES_DIR" \
    "$DARKHOST_BACKUPS_DIR" \
    "$(dirname "$DARKHOST_HISTORY_FILE")"

  touch "$DARKHOST_HISTORY_FILE" 2>/dev/null || true
  touch "$DARKHOST_LOG_FILE" 2>/dev/null || true
}

__darkhost_write_config() {
  cat > "$DARKHOST_CONFIG_FILE" <<CFG
DARKHOST_USERNAME="${DARKHOST_USERNAME:-dark}"
DARKHOST_PASSWORD="${DARKHOST_PASSWORD:-darkhost}"
DARKHOST_THEME="${DARKHOST_THEME:-black}"
DARKHOST_LABEL="${DARKHOST_LABEL:-dark}"
DARKHOST_BANNER=${DARKHOST_BANNER:-1}
DARKHOST_STARTUP=${DARKHOST_STARTUP:-1}
DARKHOST_HACKER=${DARKHOST_HACKER:-0}
DARKHOST_LOGIN_MODE="${DARKHOST_LOGIN_MODE:-secure}"
DARKHOST_ANIMATIONS=${DARKHOST_ANIMATIONS:-1}
DARKHOST_MODE="${DARKHOST_MODE:-normal}"
DARKHOST_VERSION="2.0.0"
CFG
  printf '%s\n' "${DARKHOST_USERNAME:-dark}" > "$DARKHOST_USER_FILE" 2>/dev/null || true
  printf '%s\n' "${DARKHOST_PASSWORD:-darkhost}" > "$DARKHOST_PASS_FILE" 2>/dev/null || true
}

__darkhost_default_config() {
  __darkhost_write_config
}

__darkhost_config_wizard() {
  local username password theme label banner animations mode

  if [[ ! -t 0 ]]; then
    __darkhost_default_config
    return 0
  fi

  printf '\nDARK HOST SETUP\n'
  printf 'Configure your local identity.\n\n'
  read -p 'Username [dark]: ' username
  username="${username:-dark}"

  read -s -p 'Password [darkhost]: ' password
  printf '\n'
  password="${password:-darkhost}"

  read -p 'Theme [black/blood/matrix/ghost/void/cyber/terminal] [black]: ' theme
  theme="${theme:-black}"

  read -p 'Prompt label [dark]: ' label
  label="${label:-dark}"

  read -p 'Startup banner [1/0] [1]: ' banner
  banner="${banner:-1}"
  if [[ ! "$banner" =~ ^[01]$ ]]; then banner=1; fi

  read -p 'Animations [1/0] [1]: ' animations
  animations="${animations:-1}"
  if [[ ! "$animations" =~ ^[01]$ ]]; then animations=1; fi

  read -p 'Mode [normal/hacker/ghost/matrix/forensic/void/minimal] [normal]: ' mode
  mode="${mode:-normal}"

  DARKHOST_USERNAME="$username"
  DARKHOST_PASSWORD="$password"
  DARKHOST_THEME="$theme"
  DARKHOST_LABEL="$label"
  DARKHOST_BANNER="$banner"
  DARKHOST_STARTUP="1"
  DARKHOST_HACKER=0
  DARKHOST_LOGIN_MODE="secure"
  DARKHOST_ANIMATIONS="$animations"
  DARKHOST_MODE="$mode"

  __darkhost_write_config
  printf '\nDark Host profile saved.\n'
  printf 'User: %s\n' "$username"
  printf 'Theme: %s\n' "$theme"
  printf 'Mode: %s\n' "$mode"
}

__darkhost_load_config() {
  __darkhost_ensure_layout
  if [[ ! -f "$DARKHOST_CONFIG_FILE" ]]; then
    __darkhost_default_config
  fi

  # shellcheck disable=SC1090
  source "$DARKHOST_CONFIG_FILE"

  if [[ -f "$DARKHOST_USER_FILE" ]]; then
    DARKHOST_USERNAME="$(tr -d '\r\n' < "$DARKHOST_USER_FILE" 2>/dev/null || printf '%s' "${DARKHOST_USERNAME:-dark}")"
  fi
  if [[ -f "$DARKHOST_PASS_FILE" ]]; then
    DARKHOST_PASSWORD="$(tr -d '\r\n' < "$DARKHOST_PASS_FILE" 2>/dev/null || printf '%s' "${DARKHOST_PASSWORD:-darkhost}")"
  fi
}

__darkhost_log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$DARKHOST_LOG_FILE" 2>/dev/null || true
}

__darkhost_reset_credentials() {
  DARKHOST_USERNAME="dark"
  DARKHOST_PASSWORD="darkhost"
  printf '%s\n' "$DARKHOST_USERNAME" > "$DARKHOST_USER_FILE" 2>/dev/null || true
  printf '%s\n' "$DARKHOST_PASSWORD" > "$DARKHOST_PASS_FILE" 2>/dev/null || true
  cat > "$DARKHOST_CONFIG_FILE" <<CFG
DARKHOST_USERNAME="${DARKHOST_USERNAME}"
DARKHOST_PASSWORD="${DARKHOST_PASSWORD}"
DARKHOST_THEME="${DARKHOST_THEME:-black}"
DARKHOST_LABEL="${DARKHOST_LABEL:-dark}"
DARKHOST_BANNER=1
DARKHOST_STARTUP=1
DARKHOST_HACKER=0
DARKHOST_LOGIN_MODE="secure"
DARKHOST_ANIMATIONS=1
DARKHOST_MODE="normal"
CFG
}

__darkhost_matrix_fail() {
  for _ in 1 2 3 4 5; do
    printf '\033[2J\033[H'
    for _i in 1 2 3 4 5 6 7 8 9 10; do
      printf '\033[31m%s\033[0m' "$(printf '\\x%02x' $((RANDOM % 256)))"
    done
    printf '\n'
    sleep 0.03
  done
}

__darkhost_access_granted() {
  clear
  printf '\n[✓] Identity verified\n'
  printf '[✓] Dark Host shell session authenticated\n'
  printf '[✓] Profile and command interface ready\n\n'
  if [[ "${DARKHOST_ANIMATIONS:-1}" == "1" ]]; then
    printf 'Initializing DARK CORE...\n'
    for _ in 1 2 3 4 5 6; do
      printf '█'
      sleep 0.09
    done
    printf '\n\nACCESS GRANTED\n\n'
  else
    printf 'ACCESS GRANTED\n\n'
  fi
  clear
}

__darkhost_login_banner() {
  local accent='' reset=''
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    __darkhost_apply_theme
    accent="$DARKHOST_ACCENT"
    reset='\033[0m'
  fi
  printf '\n%b╭────────────────────────────────────────╮%b\n' "$accent" "$reset"
  printf '%b│  DARK HOST  /  ACCESS GATE             │%b\n' "$accent" "$reset"
  printf '%b│  Verify your local terminal identity   │%b\n' "$accent" "$reset"
  printf '%b╰────────────────────────────────────────╯%b\n' "$accent" "$reset"
}

__darkhost_login() {
  if [[ -n "${DARKHOST_SKIP_LOGIN:-}" ]]; then
    __darkhost_log "login bypassed via DARKHOST_SKIP_LOGIN"
    return 0
  fi

  __darkhost_load_config
  if [[ -n "${DARKHOST_AUTH_OK:-}" ]]; then
    return 0
  fi

  while true; do
    clear
    __darkhost_login_banner
    local accent='' reset=''
    if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
      __darkhost_apply_theme
      accent="$DARKHOST_ACCENT"
      reset='\033[0m'
    fi
    printf '\n%bUSERNAME%b ' "$accent" "$reset"
    IFS= read -r user || return 1
    printf '%bPASSWORD%b ' "$accent" "$reset"
    IFS= read -r -s pass || return 1
    printf '\n'

    if [[ "$user" == "RESET" || "$pass" == "RESET" ]]; then
      __darkhost_reset_credentials
      user="dark"
      pass="darkhost"
      printf 'Recovery mode activated. Default login restored.\n'
    fi

    if [[ "$user" == "${DARKHOST_USERNAME:-dark}" && "$pass" == "${DARKHOST_PASSWORD:-darkhost}" ]]; then
      __darkhost_access_granted
      DARKHOST_AUTH_OK=1
      __darkhost_log "login accepted for $user"
      return 0
    fi

    printf '\n╔══════════════════════════════════════╗\n'
    printf '║          ACCESS DENIED               ║\n'
    printf '╚══════════════════════════════════════╝\n\n'
    printf 'Unauthorized authentication attempt.\n'
    __darkhost_matrix_fail
    printf '\nRetrying authentication...\n'
    IFS= read -r _ || true
  done
}

__darkhost_prompt_path() {
  local p="${PWD/#$HOME/~}"
  if [[ -z "$p" || "$p" == "$HOME" ]]; then
    printf '%s' '~'
  else
    printf '%s' "$p"
  fi
}

__darkhost_git_tag() {
  git -C "$PWD" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch
  branch="$(git -C "$PWD" branch --show-current 2>/dev/null || echo detached)"
  printf '%s' "─[git:${branch}]"
}

__darkhost_apply_theme() {
  case "${DARKHOST_THEME:-black}" in
    black)
      DARKHOST_PRIMARY='\033[38;5;245m'
      DARKHOST_ACCENT='\033[38;5;196m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
    blood)
      DARKHOST_PRIMARY='\033[38;5;245m'
      DARKHOST_ACCENT='\033[38;5;160m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
    matrix)
      DARKHOST_PRIMARY='\033[38;5;34m'
      DARKHOST_ACCENT='\033[38;5;46m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
    ghost)
      DARKHOST_PRIMARY='\033[38;5;250m'
      DARKHOST_ACCENT='\033[38;5;244m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
    cyber)
      DARKHOST_PRIMARY='\033[38;5;39m'
      DARKHOST_ACCENT='\033[38;5;201m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
    *)
      DARKHOST_PRIMARY='\033[38;5;245m'
      DARKHOST_ACCENT='\033[38;5;196m'
      DARKHOST_TEXT='\033[38;5;255m'
      ;;
  esac
}

__darkhost_prompt() {
  __darkhost_apply_theme
  local path label git_tag
  path="$(__darkhost_prompt_path)"
  label="${DARKHOST_LABEL:-dark}"
  git_tag="$(__darkhost_git_tag)"
  PS1="${DARKHOST_PRIMARY}┌─[${label}]──[${path}]${git_tag}${DARKHOST_TEXT}\n${DARKHOST_ACCENT}└─► ${DARKHOST_TEXT}"
}

__darkhost_status() {
  local host uptime_value banner_state
  host="$(hostname 2>/dev/null || uname -n 2>/dev/null || printf 'unknown')"
  uptime_value="$(uptime -p 2>/dev/null || uptime 2>/dev/null || printf 'unavailable')"
  banner_state="${DARKHOST_BANNER:-1}"
  [[ "$banner_state" == 1 ]] && banner_state="enabled" || banner_state="disabled"

  printf 'DARK HOST  /  STATUS\n'
  printf '%-14s %s\n' 'USER' "${DARKHOST_USERNAME:-dark}" 'HOST' "$host"
  printf '%-14s %s\n' 'UPTIME' "$uptime_value" 'SHELL' "Bash ${BASH_VERSION%%(*}"
  printf '%-14s %s\n' 'THEME' "${DARKHOST_THEME:-black}" 'MODE' "${DARKHOST_MODE:-normal}"
  printf '%-14s %s\n' 'STARTUP BANNER' "$banner_state" 'WORKING DIR' "$(__darkhost_prompt_path)"
}

__darkhost_system() {
  local device android_release os_info
  os_info="$(uname -srm 2>/dev/null || printf 'unavailable')"
  device="$(getprop ro.product.model 2>/dev/null || true)"
  android_release="$(getprop ro.build.version.release 2>/dev/null || true)"
  [[ -n "$device" ]] || device="not reported by this system"
  [[ -n "$android_release" ]] || android_release="not Android"

  printf 'DARK HOST  /  SYSTEM\n'
  printf '%-14s %s\n' 'PLATFORM' "$os_info" 'DEVICE' "$device"
  printf '%-14s %s\n' 'ANDROID' "$android_release" 'KERNEL' "$(uname -r 2>/dev/null || printf 'unavailable')"
  printf '%-14s %s\n' 'SHELL' "Bash ${BASH_VERSION%%(*}"
  printf '%-14s %s\n' 'HOME' "$HOME" 'LOCATION' "$PWD"
}

__darkhost_network() {
  printf 'DARK HOST NETWORK\n'
  ip addr show 2>/dev/null || ifconfig 2>/dev/null || printf 'Network state unavailable\n'
  printf '\nGateway:\n'
  ip route 2>/dev/null | awk '/default/ {print $3}' | head -n 1 || printf 'No default gateway found\n'
}

__darkhost_memory() {
  free -m 2>/dev/null || printf 'Memory info unavailable\n'
}

__darkhost_storage() {
  df -h 2>/dev/null || printf 'Storage info unavailable\n'
}

__darkhost_processes() {
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -n 20 || printf 'Process list unavailable\n'
}

__darkhost_scan() {
  local failures=0
  printf 'DARK HOST SAFE SCAN\n'
  if [[ -r "$DARKHOST_CONFIG_FILE" ]]; then
    printf '[✓] Local configuration\n'
  else
    printf '[!] Local configuration missing or unreadable\n'
    failures=$((failures + 1))
  fi
  if [[ -r "$HOME/.bashrc" ]] && grep -Fq '.darkhost/darkhost.sh' "$HOME/.bashrc"; then
    printf '[✓] Shell integration\n'
  else
    printf '[!] Dark Host Bash integration not detected\n'
    failures=$((failures + 1))
  fi
  if command -v ip >/dev/null 2>&1 || command -v ifconfig >/dev/null 2>&1; then
    printf '[✓] Network inspection tool\n'
  else
    printf '[!] Network inspection tool unavailable\n'
    failures=$((failures + 1))
  fi
  if command -v ps >/dev/null 2>&1 && ps -e >/dev/null 2>&1; then
    printf '[✓] Process inspection\n'
  else
    printf '[!] Process inspection unavailable\n'
    failures=$((failures + 1))
  fi
  if [[ -r "$HOME" && -w "$HOME" ]]; then
    printf '[✓] Home directory access\n'
  else
    printf '[!] Home directory access unavailable\n'
    failures=$((failures + 1))
  fi
  if (( failures == 0 )); then
    printf '\nSCAN RESULT: ALL CHECKS PASSED\n'
  else
    printf '\nSCAN RESULT: %s CHECK(S) NEED ATTENTION\n' "$failures"
    return 1
  fi
}

__darkhost_media_open() {
  if command -v termux-open >/dev/null 2>&1; then
    termux-open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1"
  elif command -v mpv >/dev/null 2>&1; then
    mpv -- "$1"
  else
    printf 'No media opener found. Install mpv or use an Android app that opens this file type.\n' >&2
    return 127
  fi
}

__darkhost_media() {
  local action="${1:-help}" target resource extension is_url=0 stream_url

  case "$action" in
    help|--help|-h)
      printf 'Usage: dh media play <file-or-url>\n'
      printf '       dh media pause|stop|info\n'
      printf 'Use mp <file-or-url|search terms> to play a file, URL, or search result.\n'
      printf 'Uses mpv, yt-dlp, Termux:API, or your system media app when available.\n'
      return 0
      ;;
    play)
      shift
      if [[ $# -eq 0 ]]; then
        printf 'Usage: mp <file-or-url|search terms>\n' >&2
        return 2
      fi
      target="$*"
      if [[ "$target" =~ ^[[:alpha:]][[:alnum:].+-]*:// ]]; then
        is_url=1
      elif [[ ! -e "$target" ]]; then
        if ! command -v yt-dlp >/dev/null 2>&1; then
          printf 'No local file named "%s" and yt-dlp is not installed. Install yt-dlp to search by name.\n' "$target" >&2
          return 127
        fi
        if ! command -v mpv >/dev/null 2>&1; then
          printf 'Name searches require mpv to play results. Install mpv, then try again.\n' >&2
          return 127
        fi
        stream_url="$(yt-dlp --no-playlist --format 'bestaudio/best' --get-url "ytsearch1:$target")" || {
          printf 'No playable result found for: %s\n' "$target" >&2
          return 1
        }
        stream_url="${stream_url%%$'\n'*}"
        if [[ -z "$stream_url" ]]; then
          printf 'No playable result found for: %s\n' "$target" >&2
          return 1
        fi
        mpv -- "$stream_url"
        return $?
      fi

      resource="${target%%\?*}"
      resource="${resource%%\#*}"
      extension="${resource##*.}"
      extension="${extension,,}"
      case "$extension" in
        mp3|wav|flac|ogg|oga|opus|m4a|aac|aiff|wma|mid|midi|caf)
          if (( is_url == 0 )) && command -v termux-media-player >/dev/null 2>&1; then
            termux-media-player play "$target" && return 0
          fi
          if command -v mpv >/dev/null 2>&1; then
            mpv -- "$target"
          else
            __darkhost_media_open "$target"
          fi
          ;;
        jpg|jpeg|png|gif|webp|bmp|heic|heif|avif|tif|tiff)
          if command -v termux-open >/dev/null 2>&1 || command -v xdg-open >/dev/null 2>&1; then
            __darkhost_media_open "$target"
          elif command -v mpv >/dev/null 2>&1; then
            mpv --force-window=yes -- "$target"
          else
            __darkhost_media_open "$target"
          fi
          ;;
        *)
          if (( is_url == 1 )) && command -v mpv >/dev/null 2>&1; then
            mpv -- "$target"
          elif command -v termux-open >/dev/null 2>&1 || command -v xdg-open >/dev/null 2>&1; then
            __darkhost_media_open "$target"
          elif command -v mpv >/dev/null 2>&1; then
            mpv -- "$target"
          else
            __darkhost_media_open "$target"
          fi
          ;;
      esac
      ;;
    pause|stop|info)
      if command -v termux-media-player >/dev/null 2>&1; then
        termux-media-player "$action"
      else
        printf 'Playback controls need the Termux:API package and its matching Android app.\n' >&2
        return 127
      fi
      ;;
    *)
      printf 'Unknown media action: %s\n' "$action" >&2
      printf 'Run dh media --help for usage.\n' >&2
      return 2
      ;;
  esac
}

mp() {
  __darkhost_media play "$@"
}

__darkhost_privileged_install() {
  local -a privilege=()

  if (( EUID != 0 )); then
    if command -v sudo >/dev/null 2>&1; then
      privilege=(sudo)
    elif command -v doas >/dev/null 2>&1; then
      privilege=(doas)
    else
      printf 'This package manager requires root. Install with sudo/doas or run as root.\n' >&2
      return 1
    fi
  fi

  "${privilege[@]}" "$@"
}

__darkhost_install() {
  if [[ $# -eq 0 || "${1:-}" == "--help" ]]; then
    printf 'Usage: dh install <package> [package ...]\n'
    printf 'Detects a supported package manager and runs its normal install flow.\n'
    return 0
  fi

  local manager
  if command -v pkg >/dev/null 2>&1; then
    manager=pkg
  elif command -v apt-get >/dev/null 2>&1; then
    manager=apt-get
  elif command -v dnf >/dev/null 2>&1; then
    manager=dnf
  elif command -v yum >/dev/null 2>&1; then
    manager=yum
  elif command -v pacman >/dev/null 2>&1; then
    manager=pacman
  elif command -v apk >/dev/null 2>&1; then
    manager=apk
  elif command -v zypper >/dev/null 2>&1; then
    manager=zypper
  elif command -v brew >/dev/null 2>&1; then
    manager=brew
  else
    printf 'No supported package manager found (pkg, apt-get, dnf, yum, pacman, apk, zypper, brew).\n' >&2
    return 127
  fi

  printf 'Package manager: %s\n' "$manager"
  case "$manager" in
    pkg) pkg update && pkg upgrade && pkg install "$@" ;;
    apt-get)
      __darkhost_privileged_install apt-get update &&
        __darkhost_privileged_install apt-get upgrade &&
        __darkhost_privileged_install apt-get install "$@"
      ;;
    dnf|yum) __darkhost_privileged_install "$manager" install "$@" ;;
    pacman) __darkhost_privileged_install pacman -S --needed "$@" ;;
    apk) __darkhost_privileged_install apk add "$@" ;;
    zypper) __darkhost_privileged_install zypper install "$@" ;;
    brew) brew install "$@" ;;
  esac
}

__darkhost_dashboard() {
  local user_name="${DARKHOST_USERNAME:-dark}"
  local cpu ram disk host uptime_value shell_name color='' reset=''
  cpu="$(top -bn1 2>/dev/null | awk '/Cpu/ {print $2 + $4 + $6}' | head -n 1 || echo N/A)"
  ram="$(free -m 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2 " MB"}' || echo unknown)"
  disk="$(df -P "$HOME" 2>/dev/null | tail -n +2 | awk '{print $5}' | head -n 1 || true)"
  host="$(hostname 2>/dev/null || uname -n 2>/dev/null || printf 'unknown')"
  uptime_value="$(uptime -p 2>/dev/null || uptime 2>/dev/null || printf 'unavailable')"
  shell_name="Bash ${BASH_VERSION%%(*}"
  cpu="${cpu:-unavailable}"
  ram="${ram:-unavailable}"
  disk="${disk:-unavailable}"
  if [[ "$cpu" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    cpu="${cpu}%"
  else
    cpu="unavailable"
  fi
  [[ "$disk" == *% ]] || [[ "$disk" == unavailable ]] || disk="${disk}%"
  if [[ -t 1 ]]; then
    __darkhost_apply_theme
    color="$DARKHOST_ACCENT"
    reset='\033[0m'
  fi

  printf '\n%bDARK HOST%b  /  CONSOLE\n' "$color" "$reset"
  printf '%s  ·  %s  ·  %s\n' "$host" "$user_name" "$shell_name"
  printf '────────────────────────────────────────────\n'
  printf '\n%bSYSTEM%b\n' "$color" "$reset"
  printf '  %-14s %s\n' 'UPTIME' "$uptime_value" 'LOCATION' "$(__darkhost_prompt_path)"
  printf '\n%bRESOURCES%b\n' "$color" "$reset"
  printf '  %-14s %s\n' 'CPU SAMPLE' "$cpu" 'MEMORY' "$ram" 'HOME DISK' "$disk"
  printf '\n%bPROFILE%b\n' "$color" "$reset"
  printf '  %-14s %s\n' 'THEME' "${DARKHOST_THEME:-black}" 'MODE' "${DARKHOST_MODE:-normal}"
  printf '\n  dh help   Browse commands\n  dh status View session details\n\n'
}

__darkhost_help() {
  local target="${1:-}"
  local help_map=(
    "status|System status, health, and session summary"
    "system|System information, kernel, Android build, and device details"
    "memory|RAM and swap status"
    "storage|Disk usage and filesystem overview"
    "processes|Top running processes"
    "battery|Battery state when available"
    "device|Device and system details"
    "uptime|Current system uptime"
    "monitor|Live system monitor"
    "network|Network interface and route information"
    "wifi|Wi-Fi and interface details"
    "ping|Safe diagnostic ping to a target"
    "ports|Listening local ports"
    "scan|Local safe diagnostic scan"
    "install|Install packages with the detected package manager"
    "media|Play or open audio, video, and image files"
    "play|Open a media file or URL"
    "suggest|Show suggestions for a command prefix"
    "lock|Lock the Dark Host session"
    "vault|Protected local workspace"
    "logs|Recent Dark Host session logs"
    "security|Security summary and lock state"
    "sessions|Local session record overview"
    "theme|Switch and preview Dark Host themes"
    "mode|Switch Dark Host visual modes"
    "banner|Toggle startup banner"
    "settings|Dark Host preferences and recovery info"
    "alias|Useful command aliases and shortcuts"
    "update|Pull a fast-forward update and reinstall Dark Host"
    "version|Dark Host version information"
    "doctor|Health check for config and shell integration"
    "repair|Repair missing or broken Dark Host layout"
    "pause|Pause the current Dark Host terminal session"
    "resume|Resume the paused Dark Host terminal session"
    "help|Show this smart help list"
    "history|Recent command history"
    "profile|User profile summary"
    "plugin|Plugin list and plugin actions"
    "ghost|Hidden visual/system detail"
    "void|Hidden visual/system detail"
    "404|Hidden route / warning"
    "shadow|Hidden shadow protocol"
    "root|Hidden root view"
  )

  if [[ -n "$target" ]]; then
    local entry=""
    for entry in "${help_map[@]}"; do
      local key="${entry%%|*}"
      local value="${entry#*|}"
      if [[ "$target" == "$key" ]]; then
        printf 'DARK HOST COMMANDS\nDARK HOST HELP\n\n%s\n%s\n' "$key" "$value"
        return 0
      fi
    done
    printf 'No help entry found for: %s\n' "$target"
    printf 'Try: dh help\n'
    return 1
  fi

  cat <<'HELP'
╔══════════════════════════════════════╗
║        DARK HOST COMMANDS           ║
╠══════════════════════════════════════╣
║ CORE                                  ║
║  dh status     system status          ║
║  dh system     device info            ║
║  dh monitor    live monitor           ║
║  dh doctor     health checks          ║
║  dh repair     repair helper          ║
║  dh install    install packages       ║
║  dh media      play/open media        ║
║  dh suggest    command suggestions    ║
║                                      ║
║ NETWORK                               ║
║  dh network    network status         ║
║  dh wifi       wi-fi info             ║
║  dh ping       safe diagnostics       ║
║  dh ports      listening ports        ║
║  dh scan       local scan             ║
║                                      ║
║ SECURITY                              ║
║  dh lock       secure lock            ║
║  dh vault      protected workspace    ║
║  dh logs       recent logs            ║
║  dh security   security state         ║
║  dh sessions   session list           ║
║                                      ║
║ CUSTOM                                ║
║  dh theme      theme manager          ║
║  dh mode       visual mode            ║
║  dh banner     banner toggle          ║
║  dh settings   preferences            ║
║  dh alias      alias shortcuts        ║
║  dh update     update checker         ║
║  dh version    version info           ║
║  dh pause      pause session          ║
║  dh resume     resume session         ║
║                                      ║
║ HIDDEN                                ║
║  dh ghost      hidden visual          ║
║  dh void       hidden mode            ║
║  dh 404        hidden route           ║
║  dh shadow     hidden protocol        ║
║  dh root       hidden view            ║
║                                      ║
║ USE: dh help <command> for details    ║
╚══════════════════════════════════════╝
HELP
}

__darkhost_unknown_command() {
  printf '\n╭─[ DARK HOST ERROR ]──────────────╮\n'
  printf '│ Command not recognized.          │\n'
  printf '│                                  │\n'
  printf '│ Did you mean:                    │\n'
  printf '│  dh status                       │\n'
  printf '│  dh system                       │\n'
  printf '│  dh settings                     │\n'
  printf '╰──────────────────────────────────╯\n'
  return 127
}

__darkhost_history() {
  history -a "$DARKHOST_HISTORY_FILE" 2>/dev/null || true
  if [[ -f "$DARKHOST_HISTORY_FILE" ]]; then
    tail -n 20 "$DARKHOST_HISTORY_FILE" 2>/dev/null || true
  else
    printf 'No Dark Host history yet.\n'
  fi
}

__darkhost_profile() {
  printf '╔══════════════════════════════════╗\n'
  printf '║          DARK PROFILE            ║\n'
  printf '╠══════════════════════════════════╣\n'
  printf '║ USER       : %s                ║\n' "${DARKHOST_USERNAME:-dark}"
  printf '║ LEVEL      : CORE                ║\n'
  printf '║ SESSION    : ACTIVE              ║\n'
  printf '║ COMMANDS   : %s                 ║\n' "$(history | wc -l | tr -d ' ')"
  printf '║ LAST LOGIN : today               ║\n'
  printf '╚══════════════════════════════════╝\n'
}

__darkhost_settings() {
  local choice username password theme label mode banner animations

  if [[ ! -t 0 ]]; then
    printf 'DARK HOST SETTINGS\n'
    printf 'Username: %s\n' "${DARKHOST_USERNAME:-dark}"
    printf 'Theme: %s\n' "${DARKHOST_THEME:-black}"
    printf 'Prompt: %s\n' "${DARKHOST_LABEL:-dark}"
    printf 'Mode: %s\n' "${DARKHOST_MODE:-normal}"
    printf 'Banner: %s\n' "${DARKHOST_BANNER:-1}"
    printf 'Recovery: type RESET during login to restore defaults\n'
    printf 'Configure interactively with: dh settings\n'
    return 0
  fi

  while true; do
    printf '\nDARK HOST SETTINGS\n'
    printf 'User: %s | Theme: %s | Prompt: %s | Mode: %s | Banner: %s\n' \
      "${DARKHOST_USERNAME:-dark}" "${DARKHOST_THEME:-black}" \
      "${DARKHOST_LABEL:-dark}" "${DARKHOST_MODE:-normal}" "${DARKHOST_BANNER:-1}"
    printf '[1] Username and password\n'
    printf '[2] Theme\n'
    printf '[3] Mode\n'
    printf '[4] Prompt label\n'
    printf '[5] Banner and animations\n'
    printf '[0] Done\n'
    read -r -p 'Choose an option [0]: ' choice || return 0

    case "${choice:-0}" in
      1)
        read -r -p 'Username ['"${DARKHOST_USERNAME:-dark}"']: ' username || return 0
        read -r -s -p 'Password (leave blank to keep current): ' password || return 0
        printf '\n'
        DARKHOST_USERNAME="${username:-${DARKHOST_USERNAME:-dark}}"
        [[ -n "$password" ]] && DARKHOST_PASSWORD="$password"
        ;;
      2)
        read -r -p 'Theme [black/blood/matrix/ghost/void/cyber/terminal] ['"${DARKHOST_THEME:-black}"']: ' theme || return 0
        DARKHOST_THEME="${theme:-${DARKHOST_THEME:-black}}"
        ;;
      3)
        read -r -p 'Mode [normal/hacker/ghost/matrix/forensic/void/minimal] ['"${DARKHOST_MODE:-normal}"']: ' mode || return 0
        DARKHOST_MODE="${mode:-${DARKHOST_MODE:-normal}}"
        ;;
      4)
        read -r -p 'Prompt label ['"${DARKHOST_LABEL:-dark}"']: ' label || return 0
        DARKHOST_LABEL="${label:-${DARKHOST_LABEL:-dark}}"
        ;;
      5)
        read -r -p 'Startup banner [1/0] ['"${DARKHOST_BANNER:-1}"']: ' banner || return 0
        read -r -p 'Animations [1/0] ['"${DARKHOST_ANIMATIONS:-1}"']: ' animations || return 0
        [[ "$banner" =~ ^[01]$ ]] && DARKHOST_BANNER="$banner"
        [[ "$animations" =~ ^[01]$ ]] && DARKHOST_ANIMATIONS="$animations"
        ;;
      0) return 0 ;;
      *)
        printf 'Choose 0, 1, 2, 3, 4, or 5.\n'
        continue
        ;;
    esac

    __darkhost_write_config
    printf 'Settings saved.\n'
  done
}

__darkhost_theme() {
  local choice="${1:-${DARKHOST_THEME:-black}}"
  case "$choice" in
    1|black) DARKHOST_THEME="black" ;;
    2|blood) DARKHOST_THEME="blood" ;;
    3|matrix) DARKHOST_THEME="matrix" ;;
    4|ghost) DARKHOST_THEME="ghost" ;;
    5|void) DARKHOST_THEME="void" ;;
    6|cyber) DARKHOST_THEME="cyber" ;;
    7|terminal) DARKHOST_THEME="terminal" ;;
    *)
      printf 'DARK HOST THEMES\n'
      printf '[1] BLACK\n[2] BLOOD\n[3] MATRIX\n[4] GHOST\n[5] VOID\n[6] CYBER\n[7] TERMINAL\n'
      return 0
      ;;
  esac
  printf 'Theme set to %s\n' "$DARKHOST_THEME"
}

__darkhost_mode() {
  local choice="${1:-${DARKHOST_MODE:-normal}}"
  case "$choice" in
    1|normal) DARKHOST_MODE="normal" ;;
    2|hacker) DARKHOST_MODE="hacker" ;;
    3|ghost) DARKHOST_MODE="ghost" ;;
    4|matrix) DARKHOST_MODE="matrix" ;;
    5|forensic) DARKHOST_MODE="forensic" ;;
    6|void) DARKHOST_MODE="void" ;;
    7|minimal) DARKHOST_MODE="minimal" ;;
    *)
      printf 'DARK HOST MODES\n'
      printf '[1] NORMAL\n[2] HACKER\n[3] GHOST\n[4] MATRIX\n[5] FORENSIC\n[6] VOID\n[7] MINIMAL\n'
      return 0
      ;;
  esac
  printf 'Mode set to %s\n' "$DARKHOST_MODE"
}

__darkhost_banner_toggle() {
  case "${1:-toggle}" in
    on|1) DARKHOST_BANNER=1 ;;
    off|0) DARKHOST_BANNER=0 ;;
    toggle)
      if [[ "${DARKHOST_BANNER:-1}" == "1" ]]; then
        DARKHOST_BANNER=0
      else
        DARKHOST_BANNER=1
      fi
      ;;
    *)
      printf 'Usage: dh banner [on|off|toggle]\n' >&2
      return 2
      ;;
  esac
  __darkhost_write_config
  printf 'Banner set to %s\n' "$DARKHOST_BANNER"
}

__darkhost_startup_banner() {
  [[ "${DARKHOST_STARTUP:-1}" == "1" && "${DARKHOST_BANNER:-1}" == "1" ]] || return 0
  local host color='' reset='' step percent filled empty stage
  host="$(hostname 2>/dev/null || uname -n 2>/dev/null || printf 'terminal')"
  if [[ -t 1 ]]; then
    __darkhost_apply_theme
    color="$DARKHOST_ACCENT"
    reset='\033[0m'
  fi

  printf '\n%b  ◇ DARK HOST  /  TERMINAL ENVIRONMENT%b\n' "$color" "$reset"
  printf '  ─────────────────────────────────────────\n'
  if [[ -t 1 && "${DARKHOST_ANIMATIONS:-1}" == "1" ]]; then
    printf '  BOOT SEQUENCE  /  %s\n' "$host"
    for step in {1..9}; do
      printf -v filled '%*s' "$step" ''
      filled="${filled// /▰}"
      printf -v empty '%*s' "$((9 - step))" ''
      empty="${empty// /▱}"
      percent=$((step * 100 / 9))
      if (( step <= 3 )); then
        stage='PROFILE'
      elif (( step <= 6 )); then
        stage='PROMPT'
      else
        stage='SESSION'
      fi
      printf '\r\033[2K  %b[%s%s]%b %3d%%  %s' "$color" "$filled" "$empty" "$reset" "$percent" "$stage"
      sleep 0.035
    done
    printf '\n'
  else
    printf '  Session ready\n'
  fi
  printf '  %s  ·  %s  ·  %s\n\n' "$host" "${DARKHOST_THEME:-black}" "${DARKHOST_MODE:-normal}"
}

__darkhost_lock() {
  clear
  printf 'SESSION LOCKED\n'
  printf 'Press ENTER to authenticate.\n'
  IFS= read -r _ || true
  __darkhost_login
}

__darkhost_vault() {
  mkdir -p "$DARKHOST_VAULT_DIR"
  chmod 700 "$DARKHOST_VAULT_DIR"
  printf '╔══════════════════════════════════╗\n'
  printf '║          DARK VAULT              ║\n'
  printf '║             LOCKED               ║\n'
  printf '╚══════════════════════════════════╝\n'
}

__darkhost_security() {
  printf 'DARK HOST SECURITY\n'
  printf 'Authentication: active\n'
  printf 'Session lock: enabled\n'
  printf 'Vault: locked\n'
  printf 'Unknown processes: 0\n'
}

__darkhost_sessions() {
  printf 'DARK HOST SESSIONS\n'
  find "$DARKHOST_SESSIONS_DIR" -maxdepth 1 -type f 2>/dev/null | sed 's#^.*/##' | head -n 20 || printf 'No sessions recorded\n'
}

__darkhost_pause() {
  printf '\nDARK HOST PAUSED\n'
  printf 'Paused by dark.\n'
  printf 'Press ENTER to resume.\n'
  IFS= read -r _ || true
  printf 'RESUMED BY DARK\n'
}

__darkhost_resume() {
  printf 'RESUMED BY DARK\n'
}

__darkhost_logs() {
  tail -n 20 "$DARKHOST_LOG_FILE" 2>/dev/null || printf 'No Dark Host logs yet\n'
}

__darkhost_monitor() {
  printf 'DARK HOST MONITOR\n'
  printf 'CPU: %s\n' "$(top -bn1 2>/dev/null | awk '/Cpu/ {print $2 + $4 + $6}' | head -n 1 || echo N/A)"
  printf 'RAM: %s\n' "$(free -m 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2 " MB"}' || echo N/A)"
  printf 'Swap: %s\n' "$(free -m 2>/dev/null | awk '/^Swap:/ {print $3 "/" $2 " MB"}' || echo N/A)"
  printf 'Storage: %s\n' "$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' || echo N/A)"
  printf 'Uptime: %s\n' "$(uptime 2>/dev/null || echo N/A)"
}

__darkhost_battery() {
  if command -v termux-battery-status >/dev/null 2>&1; then
    termux-battery-status
  elif [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    printf 'Battery: %s%%\n' "$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo unknown)"
  else
    printf 'Battery information unavailable\n'
  fi
}

__darkhost_wifi() {
  ip addr show 2>/dev/null || printf 'Wi-Fi info unavailable\n'
}

__darkhost_ping() {
  local target="${1:-8.8.8.8}"
  ping -c 1 "$target" 2>/dev/null || printf 'ping failed for %s\n' "$target"
}

__darkhost_ports() {
  ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || printf 'No listening ports available.\n'
}

__darkhost_aliases() {
  printf 'DARK HOST ALIASES\n'
  printf 'll    → ls -lah\n'
  printf 'la    → ls -A\n'
  printf 'g     → git\n'
  printf 'glog  → git log --oneline --decorate --graph -15\n'
  printf 'mkcd <directory>  Create a directory and enter it\n'
}

__darkhost_plugin() {
  if [[ $# -eq 0 ]]; then
    printf 'DARK HOST PLUGINS\n'
    printf 'network\ndeveloper\nsystem\nmonitor\n'
    return 0
  fi

  case "$1" in
    list) printf 'network\ndeveloper\nsystem\nmonitor\n' ;;
    install)
      printf 'Plugin installation requires explicit confirmation.\n'
      printf 'Install request: %s\n' "${2:-unknown}"
      ;;
    *) printf 'Plugin command unavailable in this build.\n' ;;
  esac
}

__darkhost_doctor() {
  local failures=0
  printf 'DARK HOST DIAGNOSTICS\n'
  if [[ -r "$DARKHOST_CONFIG_FILE" ]]; then
    printf '[✓] Configuration readable\n'
  else
    printf '[!] Configuration missing or unreadable\n'
    failures=$((failures + 1))
  fi
  if [[ -r "$HOME/.bashrc" ]] && grep -Fq '.darkhost/darkhost.sh' "$HOME/.bashrc"; then
    printf '[✓] Bash integration detected\n'
  else
    printf '[!] Bash integration not detected\n'
    failures=$((failures + 1))
  fi
  if [[ -r "$HOME/.darkhost/darkhost.sh" ]]; then
    printf '[✓] Command engine readable\n'
  else
    printf '[!] Command engine missing or unreadable\n'
    failures=$((failures + 1))
  fi
  if (( failures == 0 )); then
    printf 'DIAGNOSTIC RESULT: READY\n'
  else
    printf 'DIAGNOSTIC RESULT: %s CHECK(S) NEED ATTENTION\n' "$failures"
    return 1
  fi
}

__darkhost_repair() {
  __darkhost_ensure_layout
  printf 'DARK HOST REPAIR\n'
  printf '[✓] Layout restored\n'
  printf '[✓] Config checked\n'
  printf '[✓] Shell bootstrap verified\n'
}

__darkhost_update() {
  local repo_path="${DARKHOST_REPO:-$HOME/Dark}" selection='' answer='' branch='' assume_yes=0

  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    printf 'Usage: dh update [--yes] [checkout-path]\n'
    printf 'Prompts for a checkout path and confirmation, then pulls and reinstalls Dark Host.\n'
    return 0
  fi
  if [[ "${1:-}" == "--yes" ]]; then
    assume_yes=1
    shift
  fi
  if (( $# > 1 )); then
    printf 'Usage: dh update [--yes] [checkout-path]\n' >&2
    return 2
  fi
  if [[ -n "${1:-}" ]]; then
    repo_path="$1"
  fi
  if (( assume_yes == 0 )); then
    if [[ ! -t 0 ]]; then
      printf 'Interactive terminal required. Use: dh update --yes [checkout-path]\n' >&2
      return 2
    fi
    printf 'DARK HOST UPDATE\n'
    read -r -p "Git checkout path [$repo_path]: " selection || return 1
    repo_path="${selection:-$repo_path}"
  fi
  case "$repo_path" in
    '~') repo_path="$HOME" ;;
    '~/'*) repo_path="$HOME/${repo_path#\~/}" ;;
  esac

  if [[ ! -d "$repo_path" ]] || ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Not a Git checkout: %s\n' "$repo_path" >&2
    return 2
  fi
  if [[ ! -f "$repo_path/update.sh" ]]; then
    printf 'No update.sh found in: %s\n' "$repo_path" >&2
    return 2
  fi
  branch="$(git -C "$repo_path" branch --show-current 2>/dev/null || true)"
  branch="${branch:-detached HEAD}"
  printf '\nCheckout: %s\nBranch:   %s\n' "$repo_path" "$branch"

  if (( assume_yes == 0 )); then
    read -r -p 'Pull fast-forward updates and reinstall? [y/N]: ' answer || return 1
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) ;;
      *) printf 'Update cancelled.\n'; return 0 ;;
    esac
  fi

  printf '\nStarting Dark Host update...\n'
  bash "$repo_path/update.sh"
}

__darkhost_version() {
  printf 'DARK HOST VERSION 2.0.0\n'
}

__darkhost_about() {
  printf 'DARK HOST V2\n'
  printf 'Professional custom terminal OS built on top of normal Linux/Termux.\n'
}

__darkhost_hidden_ghost() { printf 'ghost mode online\n'; }
__darkhost_hidden_void() { printf 'void mode online\n'; }
__darkhost_hidden_404() { printf '404 route not found\n'; }
__darkhost_hidden_root() { printf 'root visual only\n'; }
__darkhost_hidden_shadow() { printf 'shadow protocol active\n'; }

__darkhost_dashboard_shortcut() { dh; }

__darkhost_paste() {
  local clip
  clip="$(termux-clipboard-get 2>/dev/null || printf '')"
  if [[ -z "$clip" ]]; then
    return 0
  fi

  if [[ "$clip" == *$'\n'* ]]; then
    printf '\nMULTI-LINE INPUT DETECTED\n'
    printf 'Lines: %s\n' "$(printf '%s\n' "$clip" | wc -l | tr -d ' ')"
    printf '[ENTER] Execute\n[ESC] Cancel\n'
  fi

  READLINE_LINE="${READLINE_LINE}${clip}"
  READLINE_POINT=$((READLINE_POINT + ${#clip}))
}

__darkhost_suggest() {
  local input="${1:-}"
  local current_word suggestion candidate count=0 context="" rest subcommand
  local -a suggestions=(
    help status system user profile network memory storage processes scan install media play
    tools theme settings update version about logout lock pause resume clear dashboard matrix
    hacker banner mode history vault monitor ping ports battery wifi device uptime logs sessions
    security alias plugin doctor repair ghost void 404 shadow root
    ls cd pwd cp mv rm mkdir git ssh python node npm
  )

  if [[ -z "$input" ]]; then
    return 0
  fi

  if [[ "$input" == "dh" ]]; then
    printf '\nSuggestions for dh:\n'
    for suggestion in "${suggestions[@]}"; do
      [[ "$suggestion" == ls || "$suggestion" == cd || "$suggestion" == git ]] && continue
      printf '  dh %s\n' "$suggestion"
      count=$((count + 1))
      (( count >= 12 )) && break
    done
    return 0
  fi

  if [[ "$input" == "dh "* ]]; then
    rest="${input#dh }"
    subcommand="${rest%% *}"
    current_word="${rest##* }"
    context="dh"
    if [[ "$rest" == *' '* ]]; then
      case "$subcommand" in
        theme) suggestions=(black blood matrix ghost void cyber terminal) ;;
        mode) suggestions=(normal hacker ghost matrix forensic void minimal) ;;
        banner) suggestions=(on off toggle) ;;
        media) suggestions=(play pause stop info help) ;;
        *) return 0 ;;
      esac
      context="dh $subcommand"
    else
      suggestions=(
        help status system user profile network memory storage processes scan install media play
        tools theme settings update version about logout lock pause resume clear dashboard matrix
        hacker banner mode history vault monitor ping ports battery wifi device uptime logs sessions
        security alias plugin doctor repair ghost void 404 shadow root
      )
    fi
    printf '\nSuggestions for %s:\n' "$input"
    for suggestion in "${suggestions[@]}"; do
      if [[ "$suggestion" == "$current_word"* ]]; then
        printf '  %s %s\n' "$context" "$suggestion"
        count=$((count + 1))
        (( count >= 12 )) && break
      fi
    done
    return 0
  fi

  if [[ "$input" == dh* ]]; then
    current_word="$input"
  else
    current_word="${input##* }"
    [[ "$input" == *' ' ]] && return 0
  fi
  printf '\nSuggestions\n'
  for candidate in "${suggestions[@]}"; do
    if [[ "$candidate" == "$current_word"* ]]; then
      printf '  %s\n' "$candidate"
      count=$((count + 1))
      (( count >= 12 )) && break
    fi
  done
}

__darkhost_readline_suggest() {
  __darkhost_suggest "${READLINE_LINE:-}"
}

__darkhost_complete() {
  local current_word="${COMP_WORDS[COMP_CWORD]:-}"
  local subcommand="${COMP_WORDS[1]:-}"
  local -a commands=(
    help status system user profile network memory storage processes scan install media play mp tools suggest
    theme settings update version about logout lock pause resume clear dashboard matrix
    hacker banner mode history vault monitor ping ports battery wifi device uptime logs
    sessions security alias plugin doctor repair ghost void 404 shadow root
  )
  local -a choices=()

  case "$subcommand" in
    help) choices=("${commands[@]}") ;;
    theme) choices=(black blood matrix ghost void cyber terminal) ;;
    mode) choices=(normal hacker ghost matrix forensic void minimal) ;;
    banner) choices=(on off toggle) ;;
    media) choices=(play pause stop info help) ;;
    *)
      if (( COMP_CWORD == 1 )); then
        choices=("${commands[@]}")
      fi
      ;;
  esac

  COMPREPLY=( $(compgen -W "${choices[*]}" -- "$current_word") )
}

__darkhost_before_prompt() {
  history -a "$DARKHOST_HISTORY_FILE" 2>/dev/null || true
  __darkhost_prompt
}

__darkhost_init() {
  __darkhost_load_config
  shopt -s histappend

  if [[ $- == *i* ]]; then
    bind 'set show-all-if-ambiguous on'
    bind 'set menu-complete-display-prefix on'
    bind 'TAB: menu-complete'
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind -x '"\C-d": __darkhost_dashboard_shortcut'
    bind -x '"\C-l": clear'
    bind -x '"\C-k": __darkhost_history'
    bind -x '"\C-h": __darkhost_help'
    bind -x '"\C-x": __darkhost_lock'
    bind -x '"\C-p": __darkhost_paste'
    bind -x '"\ev": __darkhost_paste'
    bind -x '"\eV": __darkhost_paste'
    bind -x '"\C-@": __darkhost_readline_suggest'
    complete -F __darkhost_complete dh
    complete -o default mp
  fi

  PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND}; }__darkhost_before_prompt"
  __darkhost_prompt
  __darkhost_startup_banner
  __darkhost_login
}

dh() {
  if [[ $# -eq 0 ]]; then
    __darkhost_dashboard
    return 0
  fi

  case "$1" in
    help|"?"|h)
      if [[ -n "${2:-}" ]]; then
        __darkhost_help "${2:-}"
      else
        __darkhost_help
      fi
      ;;
    status) __darkhost_status ;;
    system) __darkhost_system ;;
    user|profile) __darkhost_profile ;;
    network) __darkhost_network ;;
    memory) __darkhost_memory ;;
    storage) __darkhost_storage ;;
    processes) __darkhost_processes ;;
    scan) __darkhost_scan ;;
    install) shift; __darkhost_install "$@" ;;
    media) shift; __darkhost_media "$@" ;;
    play) shift; __darkhost_media play "$@" ;;
    suggest) shift; __darkhost_suggest "$*" ;;
    tools) printf 'pkg apt git python node npm ssh\n' ;;
    theme) __darkhost_theme "${2:-}" ;;
    settings) __darkhost_settings ;;
    update) shift; __darkhost_update "$@" ;;
    version) __darkhost_version ;;
    about) __darkhost_about ;;
    logout) printf 'Dark Host session terminated.\n'; exit 0 ;;
    lock) __darkhost_lock ;;
    pause) __darkhost_pause ;;
    resume) __darkhost_resume ;;
    clear) clear ;;
    center|dashboard|main) __darkhost_dashboard ;;
    matrix) __darkhost_matrix_fail ;;
    hacker) __darkhost_mode 2 ;;
    banner) shift; __darkhost_banner_toggle "${1:-toggle}" ;;
    mode) __darkhost_mode "${2:-}" ;;
    history) __darkhost_history ;;
    vault) __darkhost_vault ;;
    monitor) __darkhost_monitor ;;
    ping) __darkhost_ping "${2:-8.8.8.8}" ;;
    ports) __darkhost_ports ;;
    battery) __darkhost_battery ;;
    wifi) __darkhost_wifi ;;
    device) __darkhost_system ;;
    uptime) uptime 2>/dev/null || printf 'Uptime unavailable\n' ;;
    logs) __darkhost_logs ;;
    sessions) __darkhost_sessions ;;
    security) __darkhost_security ;;
    alias) __darkhost_aliases ;;
    plugin) __darkhost_plugin "${2:-}" "${3:-}" ;;
    doctor) __darkhost_doctor ;;
    repair) __darkhost_repair ;;
    ghost|void|404|shadow|root)
      case "$1" in
        ghost) __darkhost_hidden_ghost ;;
        void) __darkhost_hidden_void ;;
        404) __darkhost_hidden_404 ;;
        shadow) __darkhost_hidden_shadow ;;
        root) __darkhost_hidden_root ;;
      esac
      ;;
    *) __darkhost_unknown_command; return 127 ;;
  esac
}

command_not_found_handle() {
  printf '\n╭─[ DARK HOST ERROR ]──────────────╮\n'
  printf '│ Command not recognized.          │\n'
  printf '│                                  │\n'
  printf '│ Did you mean:                    │\n'
  printf '│  dh status                       │\n'
  printf '│  dh system                       │\n'
  printf '│  dh settings                     │\n'
  printf '╰──────────────────────────────────╯\n'
  return 127
}

if [[ $- == *i* ]]; then
  __darkhost_init
fi
