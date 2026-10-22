{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yq
    htop
    btop
    tree
    p7zip
    ripgrep
    fd
    unrar
    file
    cloudflared
    comma
    gettext
    lm_sensors
  ];
}
