# DARK Termux
export DARK_TERMUX=1
alias c='clear'
alias cls='clear'
alias ll='ls -lah'
alias la='ls -A'
if [ -z "$DARK_THEME_SHOWN" ]; then
export DARK_THEME_SHOWN=1
green='\033[1;32m'
cyan='\033[1;36m'
dim='\033[2m'
reset='\033[0m'
printf "$green\n  [ DARK HOST ]  [ STARTING ]$reset\n"
bar=''
for step in 1 2 3 4 5; do
  bar="${bar}##"
  printf '\r  %bInitializing [%-10s] %s%%%b' "$cyan" "$bar" "$((step * 20))" "$reset"
  sleep 0.04
done
device_model="$(getprop ro.product.model 2>/dev/null)"
android_release="$(getprop ro.build.version.release 2>/dev/null)"
memory_total="$(awk '/MemTotal/ { printf "%.1f GiB", $2 / 1048576 }' /proc/meminfo 2>/dev/null)"
[ -n "$device_model" ] || device_model='Android device'
[ -n "$android_release" ] || android_release='unknown'
[ -n "$memory_total" ] || memory_total='unknown'
printf '\r%b  [ DARK HOST ]  [ ONLINE ]%b\033[K\n' "$green" "$reset"
sleep 0.25
printf '\033[2J\033[H'
printf '%b╭─────────────────────────────────╮%b\n' "$green" "$reset"
printf '│%*s%*s│\n' 20 'D A R K   H O S T' 13 ''
printf '│                                 │\n'
printf '│  %bSYSTEM%b   : %-18s │\n' "$cyan" "$reset" 'ONLINE'
printf '│  %bDEVICE%b   : %-18.18s │\n' "$cyan" "$reset" "$device_model"
printf '│  %bANDROID%b  : %-18s │\n' "$cyan" "$reset" "$android_release"
printf '│  %bMEMORY%b   : %-18s │\n' "$cyan" "$reset" "$memory_total"
printf '│  %bSHELL%b    : %-18s │\n' "$cyan" "$reset" "Bash ${BASH_VERSION%%(*}"
printf '%b╰─────────────────────────────────╯%b\n\n' "$green" "$reset"
fi
PS1='\[\e[1;32m\]┌─[dark]──[\w]\n└─► \[\e[0m\]'
