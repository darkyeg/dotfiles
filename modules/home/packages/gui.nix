{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    kdePackages.kate
    whitesur-kde
    whitesur-icon-theme
  ];
}
