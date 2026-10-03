# DARK HOST — Termux Hacker Theme

A permanent DARK HOST startup theme for Termux.

## Features

- DARK HOST branding
- Hacker green colors
- Permanent startup loading
- `.bash_profile` and `.profile` fallback
- Custom prompt
- Hidden extra-key row
- Backup and restore
- GitHub update script
- No config subfolders in the repository

## Install

```bash
pkg install git -y
git clone https://github.com/mbidark/Termux-theme.git ~/Termux-theme
cd ~/Termux-theme
chmod +x *.sh
./install.sh
```

Then completely close and reopen Termux.

## Update

```bash
cd ~/Termux-theme
./update.sh
```

## Uninstall

```bash
cd ~/Termux-theme
./uninstall.sh
```

## Important

This changes the terminal's branding and startup interface. It does not change the Android application's actual name from "Termux" because that is controlled by the installed Android app.
