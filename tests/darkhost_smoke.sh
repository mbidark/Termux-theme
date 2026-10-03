#!/usr/bin/env bash
set -u
script="/workspaces/Termux-theme/darkhost.sh"
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
if [[ "$video_output" != *"MOCK OPEN <https://media.invalid/clip.mp4>"* ]]; then
  echo "FAIL: video did not route through the system media opener" >&2
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
