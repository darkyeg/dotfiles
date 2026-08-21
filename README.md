# NixOS configuration

This flake keeps shared system and Home Manager configuration separate from
host-specific desktop and WSL modules.

## Flake outputs

- `nixosConfigurations.desktop`: the full desktop system.
- `nixosConfigurations.wsl`: the lightweight NixOS-WSL system.
- `homeConfigurations."darky@desktop"`: the desktop Home Manager profile.

The `darky` username is defined once in `flake.nix` and passed to every module.
The shared Home Manager base lives in `home/profiles/base.nix`. Desktop-only GUI,
Plasma, gaming, and media modules are not loaded by WSL.

## NixOS-WSL

Apply the WSL system with:

```sh
sudo nixos-rebuild boot --flake ~/dotfiles#wsl --impure
```

When changing `wsl.defaultUser`, terminate and restart the distro from
PowerShell so the boot generation and default user take effect:

```powershell
wsl --terminate NixOS
wsl --distribution NixOS
```

## Existing desktop username migration

The configuration now declares `darky` with `/home/darky`. On an existing
desktop that still uses `yoku`, do not delete or rename the old account first.

1. Back up `/home/yoku`.
2. Rebuild `nixosConfigurations.desktop`; this creates `darky` while leaving
   the mutable legacy account and its home intact.
3. Copy the wanted files from `/home/yoku` to `/home/darky`, then fix ownership:

   ```sh
   sudo chown -R darky:users /home/darky
   ```

4. Log in as `darky` and apply `homeConfigurations."darky@desktop"`.
5. Remove the old account only after confirming the new desktop and home are
   complete.

This staged migration avoids changing the UID or moving a live user's home
during NixOS activation.
