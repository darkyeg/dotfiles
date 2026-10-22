# Install and maintain the configuration

Use the installed commands from any directory. Applying a configuration reuses
unchanged Nix store paths. Updating versions is a separate action and can download
new packages. Moving module files does not require reinstalling NixOS.

## First setup and recovery

Bootstrap starts from an installed graphical NixOS system:

```sh
bash "$HOME/dotfiles/bootstrap.sh"
```

It keeps `/etc/nixos/configuration.nix` and the installer's hardware settings. The
small system rebuild reuses the installed NixOS channel when available. Brave and
Ghostty are installed before Home Manager and developer tools.

```sh
bash bootstrap.sh --dry-run
bash bootstrap.sh --tools node,bun,claude,codex
bash bootstrap.sh --no-tools
bash bootstrap.sh --home-only
bash bootstrap.sh --full
```

`--full` chooses the primary user's full home configuration. Another account can
bootstrap essentials, register a named configuration, and select it with `hm -c`.
If a download fails, rerun the same command. Nix reuses completed paths and
`dev-setup` skips working tools.

Bootstrap logs append to `~/.local/state/dotfiles/bootstrap.log`, respecting
`XDG_STATE_HOME`. Conflicting unmanaged home files receive a unique
`.before-dotfiles-...` backup before activation.

## Apply and update

```sh
hm                         # Apply the saved home selection
os                         # Apply the saved system selection
hmu                        # Update inputs and apply home
osu                        # Update inputs and apply NixOS
update-all                 # Refresh inputs once and update the installed setup
update-all --dry           # Preview stages only
```

`update-all` reports failed stages, continues independent stages, and exits with
failure if any stage failed. Home and system selections are independent. For the
bootstrap system, a system update also refreshes the installer's NixOS channel.

Use `hm --essential` or `hm --full` for compatibility profiles. Use the existing
nh option `hm --configuration user@host` (or `-c`) for additional users and profiles.
A successful command remembers that target; failed switches and previews keep
the previous selection. Extra nh options such as `--dry` and `--no-nom` pass through.

`os --full` selects the machine configuration from this flake. `os --essential`
selects the installer configuration plus the bootstrap module. Review another
machine's hardware before selecting a full system configuration.

On a machine with several accounts, an administrator applies the shared system
configuration. Each user applies their own home target and updates their own
native developer tools. `update-all` covers the invoking user's home and tools;
it does not switch other accounts' home configurations. Identical Nix store paths
are reused across users. Each checkout retains its own `flake.lock`, so keep
checkouts on the same revision when the users should share pinned versions.

## Developer tools

```sh
dev-setup                  # Install missing Node, Bun, Claude, and Codex
dev-setup claude codex      # Install only missing selected tools
dev-update                 # Update installed tools; skip missing tools
dev-update bun             # Bun's own updater
ai-update                  # Update installed Claude and Codex
```

Node uses fnm's current LTS default and retains other project versions. Bun uses
its native installer and updater. Claude uses its native installer and updater.
Codex uses npm under the user's local data directory with a Nix-provided runtime.
Nix owns the launchers and runtime; these upstream versions remain outside the
system rebuild. Sign in to AI providers through their own authentication flows.

T3 desktop AppImages use their in-app updater. `update-all` covers the Nix
configuration and the supported developer tools, not arbitrary external apps.

## Where state lives

| State | Location |
| --- | --- |
| Checkout, home target, system target | `~/.config/dotfiles/` |
| Theme selection and schedule switch | `~/.config/dotfiles/` |
| Theme assets currently selected | `~/.local/state/dotfiles-theme/` |
| Bun | `~/.bun/` |
| Claude native executable | `~/.local/bin/claude` |
| Codex npm installation | `~/.local/share/ai-cli/` |
| Node versions | fnm's own data directory |
| Private shell environment | `~/.config/personal/` |
| VM definitions, UEFI variables, vTPM | libvirt's system state under `/var/lib/libvirt/` |

Each account has its own home state. The refactor does not migrate or delete these
directories. VM state is separate from module organization.

`DOTFILES` overrides the remembered checkout. Bootstrap supplies its checkout path
during evaluation and remembers it after successful activation. The nh default and
Neovim link use that path too. If you move the checkout, run bootstrap from its new
location with `--home-only` and your desired home profile, or set `DOTFILES` before
applying a named configuration.

## Verify and roll back

Before applying a change:

```sh
nix flake check --impure --no-build --no-write-lock-file
nh home build "$DOTFILES" --configuration full --impure
nh os build "$DOTFILES"
```

Replace `full` with your named home target. A build creates configuration artifacts
without activating them. Keep `flake.lock` unchanged for a structural refactor;
update it deliberately when you want newer software.

Home Manager retains generations; list them with `home-manager generations` and
activate a previous generation's `activate` script if needed. NixOS keeps boot
menu generations, and `sudo nixos-rebuild switch --rollback` selects the previous
system generation.

If NixOS rejects a live switch because a critical service implementation changed,
use `nh os boot "$DOTFILES"` and reboot into the new generation. Do not bypass that
check just to complete an update.

Keep `home.stateVersion` and `system.stateVersion` at the values used by the
existing installation. They control compatibility behavior, not package freshness.

## Local compatibility fixes

| Behavior | Owner and reason |
| --- | --- |
| Walker shortcut without a stuck launch indicator | `modules/home/desktop/plasma.nix` keeps Plasma's cached entry linked to its managed launcher |
| Ghostty backend | `modules/home/apps/ghostty.nix` selects epoll after the local io_uring wait-accounting issue |
| Writable GitHub CLI login config | `modules/home/apps/git.nix` leaves gh's mutable config to gh |
| Writable editor and chat preferences | Their app modules retain writable settings and seed initial values |
| Gear Lever GTK wrapper | `packages/gearlever.nix` repairs only the affected upstream wrapper shape; the AppImage module selects it |
| Native tool versions without a system rebuild | `modules/home/development/ai.nix` packages launchers; `scripts/dev-setup` owns installation and updates |

Keep a workaround with the module that owns its behavior, state why it exists,
and check its upstream condition before removing it. Runtime troubleshooting such
as a kernel clock warning is separate from a source-tree refactor.
