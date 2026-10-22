{ nixpkgs, system, ... }:
let
  # Reuse the installer's channel for the small first system rebuild.
  installedChannel = "/nix/var/nix/profiles/per-user/root/channels/nixos";
  bootstrapSource =
    if builtins.pathExists "${installedChannel}/nixos/lib/eval-config.nix"
    then builtins.toPath installedChannel
    else nixpkgs.outPath;
in
{
  bootstrap = import (bootstrapSource + "/nixos/lib/eval-config.nix") {
    inherit system;
    modules = [
      /etc/nixos/configuration.nix
      ../../modules/nixos/system/bootstrap.nix
    ];
  };
}
