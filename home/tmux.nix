{ config, pkgs, ... }:
let
  themes = {
    rose-pine = pkgs.tmuxPlugins.rose-pine;
    gruvbox = pkgs.tmuxPlugins.gruvbox;
    catppuccin = pkgs.tmuxPlugins.catppuccin;
  };
  selected = themes.${config.custom.theme} or pkgs.tmuxPlugins.rose-pine;
in {
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "tmux-256color";
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      mode-indicator
      selected
    ];

    extraConfig = builtins.readFile ./tmux/tmux.conf;
  };
}
