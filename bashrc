# DARK Termux
export DARK_TERMUX=1
alias c='clear'
alias cls='clear'
alias ll='ls -lah'
alias la='ls -A'
if [ -z "$DARK_THEME_SHOWN" ]; then
export DARK_THEME_SHOWN=1
printf '\033[1;32m'
printf '\n  [ DARK HOST ]  [ ONLINE ]  [ %s ]\n\n' "$(date '+%H:%M:%S')"
printf '\033[0m'
fi
PS1='\[\e[1;32m\]┌─[\A]─[DARK]─[\w]\n└─► \[\e[0m\]'
