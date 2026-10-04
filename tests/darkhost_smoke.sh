#!/usr/bin/env bash
set -u
script="/workspaces/Termux-theme/darkhost.sh"
repo_root="$(cd "$(dirname "$script")" && pwd)"
if [[ ! -f "$script" ]]; then
  echo "FAIL: darkhost.sh not found" >&2
  exit 1
fi
bash -lc "source '$script' >/dev/null 2>&1; dh help > /tmp/dh_help.out 2>&1; grep -q 'DARK HOST COMMANDS' /tmp/dh_help.out" 
if [[ $? -ne 0 ]]; then
  echo "FAIL: darkhost command help not working" >&2
  exit 1
fi

source "$script" >/dev/null 2>&1
pkg() {
  printf 'MOCK PKG'
  printf ' <%s>' "$@"
  printf '\n'
}
install_output="$(dh install curl "two words")"
expected_install_output=$'Package manager: pkg\nMOCK PKG <update>\nMOCK PKG <upgrade>\nMOCK PKG <install> <curl> <two words>'
if [[ "$install_output" != "$expected_install_output" ]]; then
  echo "FAIL: smart install did not update, upgrade, then preserve install arguments" >&2
  exit 1
fi

(
  unset -f pkg
  PATH=/usr/bin:/bin
  apt-get() {
    printf 'MOCK APT'
    printf ' <%s>' "$@"
    printf '\n'
  }
  sudo() { "$@"; }
  apt_output="$(dh install curl "two words")"
  expected_apt_output=$'Package manager: apt-get\nMOCK APT <update>\nMOCK APT <upgrade>\nMOCK APT <install> <curl> <two words>'
  if [[ "$apt_output" != "$expected_apt_output" ]]; then
    echo "FAIL: smart install did not update and upgrade apt before installing" >&2
    exit 1
  fi
)
if [[ $? -ne 0 ]]; then
  exit 1
fi

preserve_home="$(mktemp -d)"
HOME="$preserve_home" bash "$repo_root/install.sh" </dev/null >/dev/null
printf '\n# USER_BASHRC_PRESERVE_PROBE\n' >> "$preserve_home/.bashrc"
printf '\n# USER_PROFILE_PRESERVE_PROBE\n' >> "$preserve_home/.profile"
printf '\n# USER_TERMUX_PRESERVE_PROBE\n' >> "$preserve_home/.termux/termux.properties"
upgrade_output="$(HOME="$preserve_home" DARKHOST_UPDATE=1 bash "$repo_root/install.sh" </dev/null)"
preserved=1
grep -q USER_BASHRC_PRESERVE_PROBE "$preserve_home/.bashrc" || preserved=0
grep -q USER_PROFILE_PRESERVE_PROBE "$preserve_home/.profile" || preserved=0
grep -q USER_TERMUX_PRESERVE_PROBE "$preserve_home/.termux/termux.properties" || preserved=0
grep -q 'DARKHOST_VERSION="2.0.2"' "$preserve_home/.darkhost/config/darkhost.conf" || preserved=0
grep -q '^2.0.2$' "$preserve_home/.darkhost/VERSION" || preserved=0
[[ "$upgrade_output" != *$'\033c'* ]] || preserved=0
rm -rf "$preserve_home"
if (( preserved == 0 )); then
  echo "FAIL: update install overwrote user files or reset the terminal" >&2
  exit 1
fi

version_home="$(mktemp -d)"
(
  DARKHOST_DIR="$version_home/.darkhost"
  DARKHOST_CONFIG_DIR="$DARKHOST_DIR/config"
  DARKHOST_CONFIG_FILE="$DARKHOST_CONFIG_DIR/darkhost.conf"
  DARKHOST_HISTORY_FILE="$DARKHOST_DIR/history/history"
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
  mkdir -p "$DARKHOST_CONFIG_DIR"
  printf 'DARKHOST_VERSION="2.0.0"\n' > "$DARKHOST_CONFIG_FILE"
  __darkhost_load_config
  [[ "$DARKHOST_VERSION" == "2.0.2" ]]
)
version_load_status=$?
rm -rf "$version_home"
if (( version_load_status != 0 )); then
  echo "FAIL: stale config overrode the installed release version" >&2
  exit 1
fi

diagnostic_home="$(mktemp -d)"
if HOME="$diagnostic_home" DARKHOST_CONFIG_FILE="$diagnostic_home/missing.conf" __darkhost_scan >"$diagnostic_home/scan.out"; then
  rm -rf "$diagnostic_home"
  echo "FAIL: dh scan reported success with required files missing" >&2
  exit 1
fi
if HOME="$diagnostic_home" DARKHOST_CONFIG_FILE="$diagnostic_home/missing.conf" __darkhost_doctor >"$diagnostic_home/doctor.out"; then
  rm -rf "$diagnostic_home"
  echo "FAIL: dh doctor reported success with the installation missing" >&2
  exit 1
fi
if [[ "$(<"$diagnostic_home/scan.out")" != *"CHECK(S) NEED ATTENTION"* || \
    "$(<"$diagnostic_home/doctor.out")" != *"CHECK(S) NEED ATTENTION"* ]]; then
  rm -rf "$diagnostic_home"
  echo "FAIL: diagnostics did not describe missing installation checks" >&2
  exit 1
fi
rm -rf "$diagnostic_home"

COMP_WORDS=(dh sta)
COMP_CWORD=1
__darkhost_complete
if [[ " ${COMPREPLY[*]} " != *" status "* ]]; then
  echo "FAIL: dh subcommand completion did not suggest status" >&2
  exit 1
fi
COMP_WORDS=(dh theme ma)
COMP_CWORD=2
__darkhost_complete
if [[ " ${COMPREPLY[*]} " != *" matrix "* ]]; then
  echo "FAIL: dh theme completion did not suggest matrix" >&2
  exit 1
fi
COMP_WORDS=(dh media p)
COMP_CWORD=2
__darkhost_complete
if [[ " ${COMPREPLY[*]} " != *" play "* ]]; then
  echo "FAIL: dh media completion did not suggest play" >&2
  exit 1
fi

suggestion_output="$(__darkhost_suggest 'dh st')"
if [[ "$suggestion_output" != *"dh status"* || "$suggestion_output" != *"dh storage"* ]]; then
  echo "FAIL: command suggestions did not match the typed prefix" >&2
  exit 1
fi
suggestion_output="$(__darkhost_suggest dh)"
if [[ "$suggestion_output" != *"dh help"* ]]; then
  echo "FAIL: command suggestions did not work for the dh prefix" >&2
  exit 1
fi
suggestion_output="$( __darkhost_suggest 'dh media p' )"
if [[ "$suggestion_output" != *"dh media play"* || "$suggestion_output" != *"dh media pause"* ]]; then
  echo "FAIL: nested media suggestions did not include complete commands" >&2
  exit 1
fi

status_output="$(dh status)"
dashboard_output="$(dh)"
system_output="$(dh system)"
if [[ "$status_output" != *"DARK HOST  /  STATUS"* || "$status_output" != *"WORKING DIR"* || \
  "$status_output" != *"VERSION"* || "$status_output" != *"2.0.2"* || \
  "$(dh version)" != *"2.0.2"* || \
    "$dashboard_output" != *"RESOURCE SNAPSHOT"* && "$dashboard_output" != *"RESOURCES"* || \
    "$dashboard_output" != *"PROFILE"* || "$system_output" != *"PLATFORM"* ]]; then
  echo "FAIL: status, dashboard, or system details were incomplete" >&2
  exit 1
fi

config_write_count=0
__darkhost_write_config() { config_write_count=$((config_write_count + 1)); }
DARKHOST_STARTUP=1
DARKHOST_BANNER=1
dh banner off >/dev/null
if [[ "$DARKHOST_BANNER" != "0" || "$config_write_count" -ne 1 ]]; then
  echo "FAIL: dh banner off did not persist the setting" >&2
  exit 1
fi
startup_output="$(__darkhost_startup_banner)"
if [[ -n "$startup_output" ]]; then
  echo "FAIL: disabled banner still appeared at startup" >&2
  exit 1
fi
dh banner on >/dev/null
if [[ "$DARKHOST_BANNER" != "1" ]]; then
  echo "FAIL: dh banner on did not enable the banner" >&2
  exit 1
fi
startup_output="$(__darkhost_startup_banner)"
if [[ "$startup_output" != *"DARK HOST  /  TERMINAL ENVIRONMENT"* || "$startup_output" == *$'\033'* ]]; then
  echo "FAIL: startup intro was missing or emitted terminal escapes when redirected" >&2
  exit 1
fi

history_file="$(mktemp)"
DARKHOST_HISTORY_FILE="$history_file"
HISTFILE="$history_file"
set -o history
history -c
history -s 'DH_HISTORY_PROBE'
history_output="$(__darkhost_history)"
rm -f "$history_file"
if [[ "$history_output" != *"DH_HISTORY_PROBE"* ]]; then
  echo "FAIL: dh history did not flush current session history" >&2
  exit 1
fi

termux_media_player() { printf 'MOCK MEDIA PLAYER'; printf ' <%s>' "$@"; }
termux-media-player() { termux_media_player "$@"; }
termux-open() { printf 'MOCK OPEN <%s>' "$1"; }
mpv() { printf 'MOCK MPV'; printf ' <%s>' "$@"; }
media_args_file="$(mktemp)"
yt-dlp() {
  printf '%s\n' "$*" > "$media_args_file"
  printf 'https://stream.invalid/audio.m4a\n'
}
audio_file="$(mktemp --suffix=.mp3)"
audio_output="$(mp "$audio_file")"
rm -f "$audio_file"
if [[ "$audio_output" != *"MOCK MEDIA PLAYER <play>"* ]]; then
  echo "FAIL: mp shortcut did not route audio through Termux media controls" >&2
  exit 1
fi
image_output="$(dh play 'https://media.invalid/cover.webp')"
if [[ "$image_output" != *"MOCK OPEN <https://media.invalid/cover.webp>"* ]]; then
  echo "FAIL: image did not route through the system media opener" >&2
  exit 1
fi
video_output="$(dh media play 'https://media.invalid/clip.mp4')"
if [[ "$video_output" != *"MOCK MPV <--> <https://media.invalid/clip.mp4>"* ]]; then
  echo "FAIL: video URL did not route through the media player" >&2
  exit 1
fi
stream_output="$(mp 'https://media.invalid/watch?id=42')"
if [[ "$stream_output" != *"MOCK MPV <--> <https://media.invalid/watch?id=42>"* ]]; then
  echo "FAIL: direct media URL did not route through the media player" >&2
  exit 1
fi
search_output="$(mp lofi beats)"
if [[ "$search_output" != *"MOCK MPV <--> <https://stream.invalid/audio.m4a>"* || \
    "$(<"$media_args_file")" != *"ytsearch1:lofi beats"* ]]; then
  echo "FAIL: media name search did not resolve and play a result" >&2
  exit 1
fi
rm -f "$media_args_file"
update_help="$(dh update --help)"
if [[ "$update_help" != *"Usage: dh update [--yes] [checkout-path]"* ]]; then
  echo "FAIL: dh update help did not explain path and confirmation options" >&2
  exit 1
fi
update_error_file="$(mktemp)"
if dh update </dev/null >"$update_error_file" 2>&1; then
  rm -f "$update_error_file"
  echo "FAIL: dh update unexpectedly ran without an interactive confirmation" >&2
  exit 1
fi
if [[ "$(<"$update_error_file")" != *"Interactive terminal required"* ]]; then
  rm -f "$update_error_file"
  echo "FAIL: non-interactive dh update did not explain how to proceed" >&2
  exit 1
fi
rm -f "$update_error_file"
update_root="$(mktemp -d)"
update_repo="$update_root/checkout with spaces"
update_origin="$update_root/origin.git"
mkdir -p "$update_repo"
git init --quiet --bare --initial-branch=main "$update_origin"
git -C "$update_repo" init --quiet --initial-branch=main
git -C "$update_repo" config user.name 'Dark Host Tests'
git -C "$update_repo" config user.email 'darkhost-tests@example.invalid'
printf '2.0.2\n' > "$update_repo/VERSION"
printf '%s\n' '#!/usr/bin/env bash' 'printf "MOCK UPDATE EXECUTED\\n"' > "$update_repo/update.sh"
git -C "$update_repo" add VERSION update.sh
git -C "$update_repo" commit --quiet -m 'Add updater fixture'
git -C "$update_repo" remote add origin "$update_origin"
git -C "$update_repo" push --quiet origin main
update_output="$(dh update --yes "$update_repo")"
rm -rf "$update_root"
if [[ "$update_output" != *"Checkout: $update_repo"* || "$update_output" != *"Available version: 2.0.2"* || \
  "$update_output" != *"Update source: origin/main"* || "$update_output" != *"MOCK UPDATE EXECUTED"* ]]; then
  echo "FAIL: dh update did not run the updater from the selected checkout path" >&2
  exit 1
fi
media_control_output="$(dh media pause)"
if [[ "$media_control_output" != *"MOCK MEDIA PLAYER <pause>"* ]]; then
  echo "FAIL: media pause control was not routed through Termux media controls" >&2
  exit 1
fi

if ! dh help install | grep -q "detected package manager" || ! dh install --help | grep -q "Usage: dh install"; then
  echo "FAIL: smart install help not working" >&2
  exit 1
fi

printf 'PASS\n'
