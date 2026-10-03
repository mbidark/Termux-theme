# DARK HOST startup fallback
# Load .bashrc when .bash_profile is not used
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
