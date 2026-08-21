{ config, pkgs, ... }:
{
  gtk.gtk3.extraConfig.gtk-enable-primary-paste = false;
  gtk.gtk4.extraConfig.gtk-enable-primary-paste = false;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/dotfiles";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
}
