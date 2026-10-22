{ config, lib, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./core.nix
    ./zsh.nix
    ./tmux.nix
    ./git.nix
    ./plasma.nix
    ./walker.nix
    ./packages/ai.nix
  ];

  # Evaluated with --impure by bootstrap and the update commands.
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "25.11";
  home.sessionVariables.EDITOR = "nvim";
  home.packages = with pkgs; [ brave fnm neovim jq unzip nerd-fonts.jetbrains-mono ];
  programs.home-manager.enable = true;
  custom.font.mono = "JetBrainsMono Nerd Font";
  fonts.fontconfig.enable = true;

  programs.ghostty = {
    enable = true;
    settings = {
      command = "${pkgs.zsh}/bin/zsh";
      font-family = config.custom.font.mono;
      font-size = 13;
    };
  };

  # A fresh install has no signing key yet.
  programs.git.settings.commit.gpgsign = lib.mkForce false;
  programs.git.settings.tag.gpgsign = lib.mkForce false;

  gtk.enable = true;
  gtk.theme = { name = "adw-gtk3-dark"; package = pkgs.adw-gtk3; };
  gtk.gtk4.theme = null;
  gtk.gtk4.extraCss = ''
    @define-color window_bg_color @theme_bg_color;
    @define-color window_fg_color @theme_fg_color;
    @define-color view_bg_color @theme_base_color;
    @define-color view_fg_color @theme_text_color;
    @define-color accent_bg_color @theme_selected_bg_color;
    @define-color accent_fg_color @theme_selected_fg_color;
    @define-color popover_bg_color @theme_bg_color;
    @define-color popover_fg_color @theme_fg_color;
    @define-color error_bg_color #b3261e;
    @define-color error_fg_color #ffffff;
  '';
}
