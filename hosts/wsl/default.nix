{ username, ... }:
{
  imports = [ ../common.nix ];

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    defaultUser = username;
    docker-desktop.enable = true;
    useWindowsDriver = true;
  };
}
