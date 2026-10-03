# DARK HOST
### A custom shell layer for Termux

```text
┌─[dark]──[~]
└─► dh status
```

Give your Termux prompt a new identity without replacing the tools underneath. Dark Host adds a local sign-in screen, a configurable prompt, startup animation, and the `dh` command suite while keeping you in Bash and your normal Linux environment.

> Built for customization. Designed to stay out of the way.

## Start Here

Clone the project and run the installer:

```bash
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
| Device | `dh memory`, `dh storage`, `dh processes`, `dh battery`, `dh uptime`, `dh monitor` |
| Network | `dh network`, `dh wifi`, `dh ping`, `dh ports`, `dh scan` |
| Workspace | `dh theme`, `dh mode`, `dh banner`, `dh settings`, `dh alias`, `dh plugin` |
| Session | `dh lock`, `dh logout`, `dh pause`, `dh resume`, `dh history`, `dh logs` |
| Maintenance | `dh doctor`, `dh repair`, `dh update`, `dh help` |

Get the full list with `dh help`; get details on a command with `dh help <command>`.

## Make It Yours

Run `dh settings` to update your local credentials, theme, mode, banner, and animation preferences. The selected theme and prompt configuration are stored under `~/.darkhost/`.

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
