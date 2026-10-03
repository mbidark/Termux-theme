# DARK HOST — Termux Hacker Theme

A minimal hacker-style green Termux theme.

## Features

- Hacker green terminal
- DARK HOST startup banner
- Custom two-line prompt
- Black/green terminal palette
- Hidden Termux extra-key row
- Automatic configuration backup
- One-command GitHub update
- Uninstall / restore support

## Install

```bash
pkg install git -y
git clone https://github.com/mbidark/Termux-theme.git
cd Termux-theme
chmod +x *.sh
./install.sh
```

## Update

After a new version is pushed to GitHub:

```bash
cd ~/Termux-theme
./update.sh
```

Or:

```bash
git pull
./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Project structure

Everything is kept in the root directory:

```text
Termux-theme/
├── bashrc
├── colors.properties
├── termux.properties
├── install.sh
├── update.sh
├── uninstall.sh
├── README.md
└── LICENSE
```

## License

MIT
