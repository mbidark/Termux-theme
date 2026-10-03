# DARK Termux Theme
Advanced hacker-style Termux theme.

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

The repository folder is intentionally `~/Dark`, so the prompt shows `Dark` instead of `Termux-theme`.

## Customize

The installer creates `~/.darkrc` only when it does not already exist. Edit it to customize the intro and prompt; your file is preserved by reinstalling or updating the theme.

Available settings include `DARK_INTRO` (`1`/`0`), `DARK_INTRO_DELAY` (seconds), `DARK_PROMPT_LABEL`, `DARK_PROMPT_COLOR`, `DARK_ACCENT_COLOR`, and the `DARK_SHOW_DEVICE`, `DARK_SHOW_ANDROID`, and `DARK_SHOW_MEMORY` detail toggles. Colors: `green`, `cyan`, `blue`, `red`, `yellow`, `magenta`, or `white`.

## Shortcuts

`cl` clears the screen; `l`, `ll`, `la`, and `lt` provide common directory listings; `..`, `...`, and `....` move up one, two, or three directories. `h` shows history, `g` is Git, `glog` shows a compact graph, `dfh` and `duh` show disk usage, and `mkcd <dir>` creates then enters a directory. `reload` reloads `~/.bashrc`.

## Notes
This changes the shell prompt and startup branding. It cannot rename the Android app itself; that requires modifying/rebuilding the APK.
Uninstall leaves `~/.darkrc` in place so your personal settings are not lost.
