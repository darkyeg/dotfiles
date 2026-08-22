{ pkgs, username, ... }:
{
  imports = [ ../common.nix ];

  networking.hostName = "wsl";

  # The Codex Windows app currently expects this conventional FHS path when
  # starting its agent in WSL. NixOS-WSL already provides /bin/bash.
  systemd.tmpfiles.rules = [ "L+ /usr/bin/bash - - - - /bin/bash" ];

  # Required by Codex for Linux process sandboxing.
  environment.systemPackages = [ pkgs.bubblewrap ];

  wsl = {
    enable = true;
    defaultUser = username;
    docker-desktop.enable = true;
    useWindowsDriver = true;
  };
}
