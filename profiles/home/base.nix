{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/home/options.nix
    ../../modules/home/commands.nix
    ../../modules/home/shell/tools.nix
    ../../modules/home/shell/zsh.nix
    ../../modules/home/shell/tmux.nix
    ../../modules/home/apps/git.nix
    ../../modules/home/apps/ghostty.nix
    ../../modules/home/development/ai.nix
    ../../modules/home/development/workspace.nix
  ];

  home.stateVersion = "25.11";
  home.sessionVariables.EDITOR = "nvim";
  home.packages = with pkgs; [
    brave
    fnm
    neovim
    jq
    unzip
    nerd-fonts.jetbrains-mono
  ];

  programs.home-manager.enable = true;
  custom.font.mono = lib.mkDefault "JetBrainsMono Nerd Font";
  fonts.fontconfig.enable = true;

  gtk.gtk3.extraConfig.gtk-enable-primary-paste = false;
  gtk.gtk4.extraConfig.gtk-enable-primary-paste = false;
}
