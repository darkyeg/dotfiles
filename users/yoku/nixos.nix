{ config, lib, pkgs, ... }:
let
  identity = import ./identity.nix;
in
{
  users.users.${identity.username} = {
    isNormalUser = true;
    description = identity.name;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "storage" "video" "audio" ]
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd";
  };
}
