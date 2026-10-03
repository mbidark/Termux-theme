# DARK HOST V2
A modular hacker-style terminal environment for Termux that keeps the normal Linux environment available while adding a custom Dark Host identity, login flow, dashboard, command engine, and persistent configuration layer.

## What is included
- Secure local login layer
- Dynamic prompt with current path and git status
- `dh` command engine for status, system, network, monitor, vault, theme, profile, settings, and more
- Persistent configuration under `~/.darkhost/`
- Safe diagnostics, command help, and hidden command layer
- Startup bootstrap loaded from `.bashrc` / `.bash_profile` / `.profile`
- Backup-safe install, update, and uninstall scripts

## Install
```bash
git clone https://github.com/mbidark/Termux-theme.git ~/Dark
cd ~/Dark
chmod +x *.sh
./install.sh
```

## Update
```bash
cd ~/Dark && ./update.sh
```

## Uninstall
```bash
cd ~/Dark && ./uninstall.sh
```

## Default login
- Username: `dark`
- Password: `darkhost`
- Recovery: type `RESET` during login to restore the default credentials.

## Notes
This project intentionally layers a custom Dark Host experience on top of normal Termux/Linux. Standard commands remain available, and the environment stays compatible with Bash, Git, SSH, Python, Node, npm, and other regular Termux workflows.
