# DARK Termux
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

if [[ -f "$HOME/.darkhost/darkhost.sh" ]]; then
  . "$HOME/.darkhost/darkhost.sh"
fi

DARK_INTRO=${DARK_INTRO:-1}
DARK_INTRO_DELAY=${DARK_INTRO_DELAY:-0.04}
DARK_PROMPT_LABEL=${DARK_PROMPT_LABEL:-dark}
DARK_PROMPT_COLOR=${DARK_PROMPT_COLOR:-cyan}
DARK_ACCENT_COLOR=${DARK_ACCENT_COLOR:-green}
DARK_SHOW_DEVICE=${DARK_SHOW_DEVICE:-1}
DARK_SHOW_ANDROID=${DARK_SHOW_ANDROID:-1}
DARK_SHOW_MEMORY=${DARK_SHOW_MEMORY:-1}
if [[ ! "$DARK_INTRO_DELAY" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  DARK_INTRO_DELAY=0.04
fi
dark_color_code() {
  case "$1" in
    red) printf '\033[1;31m' ;;
    green) printf '\033[1;32m' ;;
    yellow) printf '\033[1;33m' ;;
    blue) printf '\033[1;34m' ;;
    magenta) printf '\033[1;35m' ;;
    cyan) printf '\033[1;36m' ;;
    white) printf '\033[1;37m' ;;
    *) printf '\033[1;32m' ;;
  esac
}
DARK_PROMPT_COLOR_CODE="$(dark_color_code "$DARK_PROMPT_COLOR")"
DARK_ACCENT_COLOR_CODE="$(dark_color_code "$DARK_ACCENT_COLOR")"
DARK_RESET='\033[0m'
if [[ $- == *i* ]]; then
  set -o emacs
  bind '"\e[H": beginning-of-line'
  bind '"\eOH": beginning-of-line'
  bind '"\e[1~": beginning-of-line'
  bind '"\e[F": end-of-line'
  bind '"\eOF": end-of-line'
  bind '"\e[4~": end-of-line'
  bind '"\e[3~": delete-char'
  bind '"\e[1;5C": forward-word'
  bind '"\e[1;5D": backward-word'
  bind '"\e[5C": forward-word'
  bind '"\e[5D": backward-word'
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
fi
if [[ $- == *i* && $DARK_INTRO == 1 && -z $DARK_THEME_SHOWN ]]; then
export DARK_THEME_SHOWN=1
printf '%b\n  [ DARK HOST ]  [ STARTING ]%b\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
bar=''
for step in 1 2 3 4 5; do
  bar="${bar}▰▰"
  printf '\r  %bInitializing [%-10s] %s%%%b' "$DARK_ACCENT_COLOR_CODE" "$bar" "$((step * 20))" "$DARK_RESET"
  sleep "$DARK_INTRO_DELAY"
done
if [[ $DARK_SHOW_DEVICE == 1 ]]; then
  device_model="$(getprop ro.product.model 2>/dev/null)"
  [ -n "$device_model" ] || device_model='Android device'
fi
if [[ $DARK_SHOW_ANDROID == 1 ]]; then
  android_release="$(getprop ro.build.version.release 2>/dev/null)"
  [ -n "$android_release" ] || android_release='unknown'
fi
if [[ $DARK_SHOW_MEMORY == 1 ]]; then
  memory_total="$(awk '/MemTotal/ { printf "%.1f GiB", $2 / 1048576 }' /proc/meminfo 2>/dev/null)"
  [ -n "$memory_total" ] || memory_total='unknown'
fi
printf '\r%b  [ DARK HOST ]  [ ONLINE ]%b\033[K\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
sleep 0.25
printf '\033[2J\033[H'
printf '  %b███    ██    ███  █  █%b\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET"
sleep "$DARK_INTRO_DELAY"
printf '  %b█  █  █  █  █  █ █ █%b\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET"
sleep "$DARK_INTRO_DELAY"
printf '  %b█  █  ████  ███  ██%b\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
sleep "$DARK_INTRO_DELAY"
printf '  %b█  █  █  █  █ █  █ █%b\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
sleep "$DARK_INTRO_DELAY"
printf '  %b███   █  █  █  █ █  █%b\n\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
printf '%b╭─────────────────────────────────╮%b\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
printf '│%*s%*s│\n' 20 'D A R K   H O S T' 13 ''
printf '│                                 │\n'
printf '│  %bSYSTEM%b   : %-18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" 'ONLINE'
printf '│  %bUSER%b     : %-18.18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" "${USER:-$(id -un 2>/dev/null)}"
[[ $DARK_SHOW_DEVICE == 1 ]] && printf '│  %bDEVICE%b   : %-18.18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" "$device_model"
[[ $DARK_SHOW_ANDROID == 1 ]] && printf '│  %bANDROID%b  : %-18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" "$android_release"
[[ $DARK_SHOW_MEMORY == 1 ]] && printf '│  %bMEMORY%b   : %-18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" "$memory_total"
printf '│  %bSHELL%b    : %-18s │\n' "$DARK_ACCENT_COLOR_CODE" "$DARK_RESET" "Bash ${BASH_VERSION%%(*}"
printf '%b╰─────────────────────────────────╯%b\n\n' "$DARK_PROMPT_COLOR_CODE" "$DARK_RESET"
fi
PS1="\\[$DARK_PROMPT_COLOR_CODE\\]┌─[$DARK_PROMPT_LABEL]──[\\w]\\n└─► \\[$DARK_RESET\\]"
