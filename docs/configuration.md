# Configure users and profiles

A named configuration combines a machine, a user, and a home profile. The files
under `configurations/` declare those combinations using ordinary Nix outputs.
Profiles select shared modules; users own identity and personal settings.

`flake.nix` declares external dependencies. `configurations.nix` loads top-level
`.nix` files from `configurations/nixos/` and `configurations/home/`, then combines
their named outputs. Duplicate names fail instead of replacing another target.
Adding a target file exposes a build target; it does not activate it.

## User identity

`users/yoku/identity.nix` is the source of the primary account's identity:

```nix
{
  username = "yoku";
  name = "Youssef Khalil";
  email = "me@darky.dev";
}
```

All three fields are strings. The home and NixOS user modules read this record.
Usernames, Git names, and emails do not belong in shared app or service modules.

`users/<user>/home.nix` owns personal preferences and Git signing. The SSH public
key path derives from the user's home directory. `users/<user>/nixos.nix` owns
account permissions. Docker and virtual-machine modules enable services; they do
not grant access to a particular username.

## Home profiles

| Profile | Includes |
| --- | --- |
| `base.nix` | Shell, terminal, browser, basic Neovim, developer-tool commands |
| `essential.nix` | Base plus Plasma shortcuts, Walker, and a small GTK theme |
| `full.nix` | Base plus the configured desktop themes, editors, languages, media and tools |

Profiles mostly contain imports. Put reusable behavior in a module and select it
from the relevant profiles. Add a common package to `base.nix` only when every
profile should receive it.

The current named configurations are:

- `<primary-user>@desktop`: the full profile and that user's preferences.
- `<primary-user>@desktop-essential`: essentials and the same user's preferences.
- `full`: compatibility alias for the primary user's full configuration.
- `essential`: essentials for the account running the command, used by bootstrap.

The bootstrap `essential` configuration reads `USER` and `HOME`, so use `--impure`.
It leaves personal Git identity unset. Select a named home target to use the
identity explicitly imported by that user's `home.nix`, or configure Git yourself.

Select a configuration once; later `hm`, `hmu`, and `update-all` reuse it:

```sh
hm --configuration "${USER}@$(uname -n)-essential"
hm --configuration "${USER}@$(uname -n)"
```

The examples refer to the existing `desktop` host. Register an output for another
host before selecting its name.

## Add a profile for an existing user

Create `profiles/home/work.nix` using the same module pattern:

```nix
{ pkgs, ... }:
{
  imports = [
    ./base.nix
    ../../modules/home/desktop/plasma.nix
    ../../modules/home/desktop/walker.nix
    ../../modules/home/theme/essential.nix
  ];

  home.packages = [ pkgs.thunderbird ];
}
```

Create `configurations/home/work.nix`; the loader finds it automatically:

```nix
{ mkHome, ... }:
let
  home = mkHome [
    ../../profiles/home/work.nix
    ../../users/yoku/home.nix
  ];
in
{
  "${home.config.home.username}@desktop-work" = home;
}
```

The home module supplies the username and preferences; the target does not import
identity separately. This reuses the same user with a different app selection.
Run `hm --configuration "${USER}@desktop-work"` to select it. Switching replaces
one user's managed home configuration; it does not create another Linux account
or erase application data.

## Add another user

For `yoku` and `darky` on the same machine, keep the existing user and add the
second one. Create `users/darky/identity.nix` with that account's three identity
fields. Create `users/darky/home.nix`:

```nix
{ config, ... }:
let
  identity = import ./identity.nix;
in
{
  home.username = identity.username;
  home.homeDirectory = "/home/${config.home.username}";
  programs.git.settings.user = {
    name = identity.name;
    email = identity.email;
  };
}
```

Create `users/darky/nixos.nix` if this machine should have the Linux account:

```nix
{ pkgs, ... }:
let
  identity = import ./identity.nix;
in
{
  users.users.${identity.username} = {
    isNormalUser = true;
    description = identity.name;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" ];
  };
}
```

Add `../../users/darky/nixos.nix` to `hosts/desktop/default.nix` alongside the
existing user import. Add `wheel` only for an administrator; select Docker and
libvirt access per account. Set a new account's password locally or configure its
SSH access; keep credentials outside the repository. See the
[NixOS user-management manual](https://nixos.org/manual/nixos/stable/#sec-user-management).

Create `configurations/home/darky.nix`:

```nix
{ mkHome, ... }:
let
  home = mkHome [
    ../../profiles/home/essential.nix
    ../../users/darky/home.nix
  ];
in
{
  "${home.config.home.username}@desktop" = home;
}
```

Choose `full.nix` instead if both users should receive the same apps. For a
different selection, create a profile as described above; shared app modules stay
in one place. Nothing changes in `flake.nix` or the shared loader.

Build both the system and new home target before applying them. An administrator
applies the system configuration to create the account. Log in as the new user,
give them their own checkout, and run `bash bootstrap.sh --home-only --no-tools`
there for their first Home Manager activation. Open a new terminal, then select
their named target:

```sh
hm --configuration "${USER}@desktop"
```

Each account has its own saved target, application state, developer tools, and AI
sign-ins. Nix-managed packages with the same store path are shared. `update-all`
applies the invoking user's home selection; it does not activate every user's
home. Each user runs their own home commands.

## Change an existing username

On a fresh installation or fork, set `username = "darky";` in the selected identity
record before creating the account. The NixOS and home modules read that value,
and the named home outputs derive from it. The directory can remain `users/yoku/`
or be renamed with its imports updated; the directory name does not select the
account.

On an existing installation, editing that value is only the configuration change.
It does not migrate the live account, its files, or its saved target selection.
Plan that migration separately from another administrator session: preserve the
existing UID, groups, and file ownership; decide whether to retain or move the
home directory; and carry over keys, authentication, and application state.
Update paths and select the new named home target after the account migration.

Check host storage ownership too. This desktop's Windows-volume mounts explicitly
use UID `1000` in `hosts/desktop/storage.nix`; adding another user does not grant
them the same ownership. A username rename should retain the original numeric
owner unless a separate storage change is intended.

## Fork this repository

Change the identity record and user preferences first. Folder names identify
configuration files; the identity record declares the account name. For an
existing account, follow the migration guidance above before applying a rename.
You may rename the user directory too, updating its imports in the host and
the relevant files under `configurations/home/`.

Keep shared modules free of personal identity, machine disk IDs, credentials, and
account-specific group assignments. This lets another user select the same apps
without inheriting your identity or permissions.

For a fresh machine, start with bootstrap. Register your own host before selecting
a full system configuration.

## Add a machine

Create `hosts/<host>/` with its own hardware configuration and service imports.
Reuse modules under `modules/nixos/`, then add a `nixosConfigurations.<host>` entry
using the existing `nixpkgs.lib.nixosSystem` pattern. Add home outputs for the user
and host combinations you need. The shared loader needs no changes.

For example, create `configurations/nixos/laptop.nix` after creating
`hosts/laptop/default.nix`:

```nix
{ inputs, nixpkgs, system, ... }:
{
  laptop = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ ../../hosts/laptop ];
  };
}
```

That host should set `networking.hostName = "laptop"`. Create
`configurations/home/laptop.nix` using an existing profile and user module:

```nix
{ mkHome, ... }:
let
  home = mkHome [
    ../../profiles/home/essential.nix
    ../../users/yoku/home.nix
  ];
in
{
  "${home.config.home.username}@laptop" = home;
}
```

Use that machine's installer-generated hardware configuration. Review storage,
GPU drivers, boot settings, locale, and user imports. The original desktop's
`storage.nix` contains its drive IDs and ownership settings.

No laptop or WSL target is registered now. Bootstrap currently supports installed
NixOS desktops. Ubuntu needs its own home profile and setup path; running this
bootstrap there exits before changing the system.

## Choose desktops per user

A future desktop belongs in its own NixOS session module and home desktop module.
A profile can select those modules without copying shell, app, or identity files.
The host enables the installed desktop sessions. Home profiles select each user's
desktop settings, shortcuts, and apps. Enabling a Home Manager desktop module
alone does not register the corresponding NixOS login session; the
[Home Manager Hyprland documentation](https://nix-community.github.io/home-manager/options/home-manager/wayland.html#opt-wayland.windowManager.hyprland.enable)
explains this division.

After implementing and checking the additional desktop modules, these combinations
fit the existing structure:

| Desired setup | Host imports | Home selection |
| --- | --- | --- |
| Both users use Plasma | Plasma session and both account modules | Each user's home plus the same or different app profiles |
| `yoku` uses Plasma, `darky` uses Hyprland | Both sessions and both account modules | Plasma settings for `yoku`; Hyprland settings for `darky` |
| `yoku` chooses either session at login | Both sessions and the existing account module | One home configuration importing compatible settings for both desktops |
| `yoku` switches between alternative setups | The sessions those setups require | Separate named home targets, selected with `hm --configuration` |

Login-session choice does not switch Home Manager targets. Alternative targets
replace the user's active managed configuration when applied. To keep both
desktops ready at login, compose their home modules in one profile and resolve
shared theme, portal, and service settings explicitly. System-installed sessions
are available on the host; a home profile is not an access restriction.

The current `full.nix` and `essential.nix` profiles both include Plasma. A future
Hyprland profile should reuse `base.nix` and the desired app modules, then select
its own desktop module. No Hyprland module or target is registered yet.

## Custom packages

Put a local package recipe in `packages/`, then select it from the module or
profile that needs it. The recipe defines how to build the package; the consumer
decides where to install it. `packages/gearlever.nix` is the existing example:
the AppImage module selects its corrected upstream package with `pkgs.callPackage`.
Top-level `.nix` recipes are also exposed as standard flake package outputs,
using each filename as its package name. Subdirectories can hold source files
and helpers; they are not scanned.

For a custom command, create `packages/project-root.nix`:

```nix
{ writeShellApplication, git }:
writeShellApplication {
  name = "project-root";
  runtimeInputs = [ git ];
  text = ''exec git rev-parse --show-toplevel "$@"'';
}
```

Build it with `nix build .#project-root`. To install it, select it in a home
profile using the path relative to that profile:

```nix
{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../packages/project-root.nix {}) ];
}
```

For third-party source builds, keep the version, source revision, fixed hash,
dependencies, and build steps together in the package recipe. For upstream
packages, use `override` or `overrideAttrs` there and preserve the upstream hooks
you still need. A custom package follows the normal Nix build and update flow;
it does not need a separate installer. Adding a recipe alone does not install it.

Use an overlay when several consumers must receive the replacement as
`pkgs.<name>`. A package selected by one module can stay an explicit `callPackage`.
Packages already available in nixpkgs only need `pkgs.<name>` in the appropriate
package list. They do not need a new flake input. External inputs are for upstream
modules or packages the configuration actually consumes.

Keep `flake.nix` for dependency declarations and `configurations.nix` for loading
outputs rather than package build logic. New Git-backed flake files must be visible
to Git before evaluation; `git add -N <path>` makes them visible without a commit.

## Edit apps and configuration files

Use `modules/home/apps/` for app settings, `development/` for toolchains and tool
updaters, `shell/` for shell behavior, `desktop/` for launcher integration, and
`theme/` for appearance. Package-only groups live under `modules/home/packages/`.

Editable Neovim files live under `config/nvim`; shell functions and tmux settings
live under `config/zsh` and `config/tmux`. Neovim's link uses the selected repository
path rather than a username embedded in the module.
