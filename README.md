# Dotfiles

Start with the graphical NixOS installer and a working desktop/network connection.
Clone this repository, then run the bootstrap. `nix-shell` supplies Git even on
a fresh install where Git is missing:

```sh
nix-shell -p git --run 'git clone https://github.com/darkyeg/dotfiles.git "$HOME/dotfiles"'
bash ~/dotfiles/bootstrap.sh
```

The default setup keeps `/etc/nixos/configuration.nix` and its hardware settings,
adds Brave, Ghostty, Git, and support for native binaries, then applies a small
Home Manager profile. Brave is installed before the home configuration and dev
tools. The first system rebuild reuses the installer's NixOS channel when one
exists, avoiding an unrelated switch to the repository's newer system packages.
Regular desktop apps stay managed by Nix.

The essentials profile includes the shell, terminal, browser, Walker launcher
(Alt + Space), basic Neovim, fnm, and the dev-tool commands. It leaves language
toolchains, extra editors, Playwright browsers, media apps, and games for later.
Node versions, Bun, Claude, and Codex use their own installers for quick updates.
AI authentication still happens through each provider's sign-in flow.

Preview or customize the setup:

```sh
bash bootstrap.sh --dry-run
bash bootstrap.sh --tools bun,claude,codex
bash bootstrap.sh --no-tools
bash bootstrap.sh --home-only       # Existing system already configured
bash bootstrap.sh --full            # Full Home Manager apps; longer download
```

Rerun the same command after a failed download. Nix reuses completed store paths
and `dev-setup` skips installed tools. Logs append to
`~/.local/state/dotfiles/bootstrap.log`. The script never updates the lock file
automatically. Initial downloads still depend on connection speed and cache
availability.

Conflicting unmanaged home configuration files are backed up beside the original
with a unique `.before-dotfiles-...` extension before Home Manager takes over.

## Everyday commands

These are installed commands that work from any directory and shell:

| Command | Action |
| --- | --- |
| `update-all` | Refresh pinned versions, apply system and home, update installed dev tools |
| `hm` | Apply the selected Home Manager profile |
| `hmu` | Update flake inputs and apply that home profile |
| `os` | Apply the selected system profile |
| `osu` | Update flake inputs and apply that system profile |
| `hm --full` | Switch to the full home setup |
| `hm --essential` | Switch to the essentials home setup |
| `ai-update` | Update installed Claude and Codex |
| `dev-update` | Update installed Node, Bun, Claude, and Codex |
| `dev-update bun` | Update only Bun |
| `dev-setup claude codex` | Install just the missing selected tools |

Use `update-all --dry` to preview its stages. It refreshes the lock file once,
then applies the selected profiles; an individual failure does not stop unrelated
updates. For the bootstrap system profile it also updates the installer's NixOS
channel. T3 desktop AppImages keep their own in-app updater.

`dev-setup` with no arguments installs missing tools from all four supported
tools. `dev-update` skips tools you have not installed. Updating Node selects
the latest LTS as fnm's default and retains older project versions.

Home and system profiles are remembered separately in `~/.config/dotfiles`.
After bootstrap, `os` continues using the installer-created system configuration
plus the small bootstrap module. `os --full` selects the existing machine-specific
system flake; review its hardware/drive configuration before using it on another
machine. The full home profile retains the identity in `home/yoku.nix`; essentials
uses the user running the script. Set `DOTFILES` to override the saved checkout.
