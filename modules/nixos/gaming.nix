{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protontricks
    winetricks
    lutris
    heroic
    bottles
    goverlay
  ];
}
