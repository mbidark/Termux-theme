# DARK HOST Termux Theme
# Main theme configuration

export TERM_PROGRAM="DARK HOST"
export DARK_HOST="1"

alias cls='clear'
alias c='clear'
alias ll='ls -lah'
alias la='ls -A'

# Prevent duplicate banner when bashrc is sourced manually
if [ -z "$DARK_HOST_BANNER_SHOWN" ]; then
    export DARK_HOST_BANNER_SHOWN=1

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
fi

PS1='\[\e[1;32m\]┌─[\A]──[\u@\h]──[\w]\n└─► \[\e[0m\]'
