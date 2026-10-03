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
printf 'PASS\n'
