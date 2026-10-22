# NixOS dotfiles

A configuration is a machine, a user, and a home profile. User identity lives in
one file; profiles select shared modules; each app owns its settings. The included
profiles use Plasma. Other desktops can be added through their own modules.

## Start on a fresh NixOS installation

Use the graphical installer first, with a working desktop and network connection.
Then clone the repository and run the resumable bootstrap:

```sh
nix-shell -p git --run 'git clone https://github.com/darkyeg/dotfiles.git "$HOME/dotfiles"'
bash "$HOME/dotfiles/bootstrap.sh"
```

The default keeps the installer's hardware configuration, installs Brave and
Ghostty, applies the essentials home profile, and installs missing developer
tools. Completed downloads are reused when you rerun it. Regular apps stay managed
by Nix; Node, Bun, Claude, and Codex retain their own fast update paths.

```sh
bash bootstrap.sh --dry-run
bash bootstrap.sh --tools bun,claude,codex
bash bootstrap.sh --no-tools
bash bootstrap.sh --home-only
```

The included [desktop host](hosts/desktop/README.md) has machine-specific hardware
and storage settings. Configure your own host before using `os --full` on another PC.

## Find the right file

| Change | Location |
| --- | --- |
| Username, display name, Git email | `users/<user>/identity.nix` |
| User preferences and Git signing | `users/<user>/home.nix` |
| User account and permissions | `users/<user>/nixos.nix` |
| Apps included in a profile | `profiles/home/` |
| An app's settings | `modules/home/apps/` |
| Shell, languages, desktop, or theme | Their directories under `modules/home/` |
| Host services, hardware, drives, locale | `hosts/<host>/` |
| Reusable NixOS settings | `modules/nixos/` |
| Custom package recipes and package patches | `packages/` |
| Update and theme command implementations | `scripts/` |
| Editor and shell configuration files | `config/` |
| External dependency declarations and pinned versions | `flake.nix` and `flake.lock` |
| Named machine and home configurations | `configurations/nixos/` and `configurations/home/` |
| Shared target loading and package set | `configurations.nix` |

## Everyday commands

These commands work from any directory:

| Command | Action |
| --- | --- |
| `hm` / `os` | Apply the saved home / system selection |
| `hmu` / `osu` | Update inputs and apply that selection |
| `hm --essential` / `hm --full` | Select an existing compatibility profile |
| `hm --configuration user@host` | Select and remember a named home configuration |
| `update-all` | Update Nix inputs, apply system and home, update installed dev tools |
| `update-all --dry` | Preview those stages |
| `dev-setup bun` | Install Bun only if missing |
| `dev-update` | Update installed Node, Bun, Claude, and Codex |
| `dev-update bun` / `ai-update` | Update Bun only / installed AI CLIs |

The `full` alias belongs to the primary user. Additional users and profiles use
named configurations. Home and system selections are remembered separately.

- [Compose profiles, add users, fork, and add a machine](docs/configuration.md)
- [Install, update, verify, recover, and locate runtime state](docs/maintenance.md)
- [Rules for AI contributors](AGENTS.md)
