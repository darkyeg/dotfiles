{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brave
    google-chrome
    kdePackages.kate
    whitesur-kde
    whitesur-icon-theme
  ];
}
