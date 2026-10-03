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

if ! dh help install | grep -q "detected package manager" || ! dh install --help | grep -q "Usage: dh install"; then
  echo "FAIL: smart install help not working" >&2
  exit 1
fi

printf 'PASS\n'
