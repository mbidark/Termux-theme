# DARK HOST — Hacker Terminal Theme

clear

printf '\033[1;32m'
cat <<'EOF'
╔══════════════════════════════════╗
║        D A R K   H O S T         ║
║                                  ║
║   SYSTEM  : ONLINE               ║
║   SHELL   : BASH                 ║
║   STATUS  : SECURE               ║
╚══════════════════════════════════╝
EOF
printf '\033[0m'

alias cls='clear'
alias c='clear'
alias ll='ls -lah'
alias la='ls -A'

# Green hacker-style prompt
PS1='\[\e[1;32m\]┌─[\A]──[\u@\h]──[\w]\n└─► \[\e[0m\]'
