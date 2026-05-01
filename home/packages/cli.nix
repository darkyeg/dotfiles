{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    yq
    htop
    btop
    tree
    unzip
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
