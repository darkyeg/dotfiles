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
    signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  };
  programs.git.settings.gpg.format = "ssh";
  programs.git.settings.commit.gpgsign = true;
  programs.git.settings.tag.gpgsign = true;

  custom.font.mono = "JetBrainsMono Nerd Font";
  custom.themeAuto = {
    enable = true;
    mode = "solar";
    latitude = 30.0444;
    longitude = 31.2357;
    timeZone = "Africa/Cairo";
  };
}
