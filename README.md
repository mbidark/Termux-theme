# DARK HOST
### A custom shell layer for Termux

```text
┌─[dark]──[~]
└─► dh status
```

Give your Termux prompt a new identity without replacing the tools underneath. Dark Host adds a local sign-in screen, a configurable prompt, startup animation, and the `dh` command suite while keeping you in Bash and your normal Linux environment.

> Built for customization. Designed to stay out of the way.

## Start Here

For a fresh Termux install, copy and run this single line:

```bash
pkg update && pkg upgrade && pkg install git && git clone https://github.com/mbidark/Termux-theme.git ~/Dark && cd ~/Dark && chmod +x ./*.sh && ./install.sh
```

Or run the steps separately:

```bash
pkg update && pkg upgrade && pkg install git
git clone https://github.com/mbidark/Termux-theme.git ~/Dark
cd ~/Dark
chmod +x ./*.sh
./install.sh
```

On a first interactive install, the setup wizard asks for a username, password, theme, prompt label, mode, banner, and animation preferences. On later installs, it offers to reconfigure the profile. Restart Termux when installation finishes.

If the installer runs without an interactive terminal, it creates the default profile: `dark` / `darkhost`. Change these credentials with `dh settings`.

## Command Deck

| Area | Commands |
| --- | --- |
| Overview | `dh`, `dh status`, `dh system`, `dh user`, `dh version`, `dh about` |
| Device | `dh memory`, `dh storage`, `dh processes`, `dh battery`, `dh uptime`, `dh monitor`, `dh media` |
| Network | `dh network`, `dh wifi`, `dh ping`, `dh ports`, `dh scan` |
| Workspace | `dh theme`, `dh mode`, `dh banner`, `dh settings`, `dh alias`, `dh plugin` |
| Session | `dh lock`, `dh logout`, `dh pause`, `dh resume`, `dh history`, `dh logs` |
| Maintenance | `dh install <package>`, `dh doctor`, `dh repair`, `dh update`, `dh help` |

Get the full list with `dh help`; get details on a command with `dh help <command>`. Press Tab after `dh` to complete commands, Ctrl+Space to show word suggestions for the current command line, and use the arrow keys to search command history. Paste clipboard text with Alt+V, Alt+Shift+V, or Ctrl+P.

Open local media or a URL with the short command `mp <file-or-url>`, or use `dh media play <file-or-url>`. Bash filename completion works with `mp` for local files. Audio uses Termux:API when available, otherwise Dark Host tries `mpv` or the system opener. Video and pictures open in the Android or desktop app associated with that file type, with `mpv` as a fallback. `dh media pause`, `stop`, and `info` use Termux:API controls.

For Termux playback controls, install the `termux-api` package and its matching Termux:API Android app. `mpv` can be installed as an optional player with `dh install mpv`. Playback depends on the installed app and codecs; no single player supports literally every format.

Install packages with the detected system package manager:

```bash
dh install git
```

Dark Host detects Termux `pkg`, Debian/Ubuntu `apt-get`, Fedora `dnf`/`yum`, Arch `pacman`, Alpine `apk`, openSUSE `zypper`, or Homebrew. Before installing, the Termux path runs `pkg update` and `pkg upgrade`; Debian/Ubuntu runs `apt-get update` and `apt-get upgrade`. On Linux, it uses `sudo` or `doas` when elevated access is needed. The package manager handles its normal prompts; no shell evaluation or silent auto-confirm is used. Run `dh install --help` for usage.

## Make It Yours

Run `dh settings` for a menu that stays open while you change credentials, theme, mode, prompt label, banner, and animation preferences. Each change is saved immediately. Use `dh banner on` or `dh banner off` to control the startup banner directly. Settings are stored under `~/.darkhost/`.

Available themes include `black`, `blood`, `matrix`, `ghost`, `void`, `cyber`, and `terminal`. Modes include `normal`, `hacker`, `ghost`, `matrix`, `forensic`, `void`, and `minimal`.

## Update or Remove

To update from the repository:

```bash
cd ~/Dark
git pull --ff-only
./install.sh
```

To remove the shell layer and restore backed-up startup files:

```bash
cd ~/Dark
./uninstall.sh
```

## Under the Hood

- Bash functions and startup files provide the Dark Host layer; standard shell commands remain available.
- User settings and session data live in `~/.darkhost/`.
- The installer backs up existing shell and Termux settings in `~/.dark-backup/` before installing.
- No root access or replacement shell is required.

**Security note:** Dark Host's sign-in is a shell-level gate, not Android or Linux account security. Credentials are stored locally in the user's home directory, so do not reuse sensitive passwords. The non-interactive install defaults are `dark` / `darkhost`; replace them before relying on the sign-in screen.
