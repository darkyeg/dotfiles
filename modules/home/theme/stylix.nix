{ config, pkgs, lib, ... }:
let
  u = config.custom;

  schemes = {
    gruvbox = { dark = "gruvbox-dark-hard"; light = "gruvbox-light-hard"; };
    rose-pine = { dark = "rose-pine"; light = "rose-pine-dawn"; };
    catppuccin = { dark = "catppuccin-mocha"; light = "catppuccin-latte"; };
  };
  schemeName = schemes.${u.theme}.${u.colorScheme};

  monoPackages = {
    "GeistMono Nerd Font" = pkgs.nerd-fonts.geist-mono;
    "JetBrainsMono Nerd Font" = pkgs.nerd-fonts.jetbrains-mono;
    "FiraCode Nerd Font" = pkgs.nerd-fonts.fira-code;
  };

  uiPackages = {
    "Inter" = pkgs.inter;
    "Geist" = pkgs.geist-font;
  };
in {
  home.packages = [
    monoPackages.${u.font.mono}
    uiPackages.${u.font.ui}
    pkgs.dejavu_fonts
    pkgs.noto-fonts-color-emoji
  ];

  fonts.fontconfig.enable = true;

  stylix = {
    enable = true;
    polarity = u.colorScheme;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";

    image = lib.mkIf (u.wallpaper != null) u.wallpaper;

    fonts = {
      monospace = {
        package = monoPackages.${u.font.mono};
        name = u.font.mono;
      };
      sansSerif = {
        package = uiPackages.${u.font.ui};
        name = u.font.ui;
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        terminal = 13;
        applications = 12;
        desktop = 11;
        popups = 11;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    targets.gtk.enable = lib.mkDefault false;
    targets.kde.enable = lib.mkDefault false;
    targets.zed.enable = lib.mkDefault false;
    targets.vesktop.enable = false;
    targets.rofi.enable = false;
    targets.tmux.enable = false;
    targets.ghostty.enable = false;
    targets.spicetify.enable = false;
    targets.vscode.enable = false;
  };
}
