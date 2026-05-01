{ config, ... }:
let
  themes = {
    gruvbox = { dark = "Gruvbox Dark Hard"; light = "Gruvbox Light Hard"; };
    rose-pine = { dark = "Rose Pine"; light = "Rose Pine Dawn"; };
    catppuccin = { dark = "Catppuccin Mocha"; light = "Catppuccin Latte"; };
  };
  fallback = { dark = "Gruvbox Dark Hard"; light = "Gruvbox Light Hard"; };
  t = themes.${config.custom.theme} or fallback;
in {
  programs.ghostty = {
    enable = true;
    settings = {
      theme = t.${config.custom.colorScheme};
      font-family = config.custom.font.mono;
      font-size = 13;
      window-decoration = "client";
      shell-integration-features = "no-cursor,sudo,no-title";
      cursor-style = "block";
      adjust-cell-height = "35%";
      mouse-hide-while-typing = true;
      window-padding-balance = true;
      window-save-state = "always";
      background-opacity = 0.90;
      background-blur = true;
    };
  };
}
