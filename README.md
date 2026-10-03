# DARK HOST Termux Theme

A minimal, dark, hacker-style theme for Termux.

## Features

- DARK HOST startup banner
- Custom two-line terminal prompt
- Dark color palette
- Hidden Termux extra-key / shortcut bar
- Useful aliases
- Automatic configuration backups
- Simple uninstall / restore script

## Install

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/dark-host-termux.git
cd dark-host-termux
chmod +x install.sh uninstall.sh
./install.sh
```

Restart Termux, or run:

```bash
source ~/.bashrc
```

## Uninstall

From the project directory:

```bash
./uninstall.sh
```

The installer stores backups in:

```text
~/.dark-host-backup
```

## Files

```text
dark-host-termux/
├── install.sh
├── uninstall.sh
├── README.md
├── LICENSE
└── config/
    ├── bashrc
    ├── colors.properties
    └── termux.properties
```

## License

MIT
