{ config, lib, ... }:
let
  stateDir = "${config.home.homeDirectory}/.config/dotfiles";
  readState = name: default:
    let f = "${stateDir}/${name}"; in
    if builtins.pathExists f
    then lib.strings.trim (builtins.readFile f)
    else default;
in {
  options.custom = {
    theme = lib.mkOption {
      type = lib.types.enum [ "rose-pine" "gruvbox" "catppuccin" ];
      default = readState "theme" "gruvbox";
    };

    colorScheme = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = readState "colorScheme" "dark";
    };

    font.mono = lib.mkOption {
      type = lib.types.str;
      default = "GeistMono Nerd Font";
    };

    font.ui = lib.mkOption {
      type = lib.types.str;
      default = "Inter";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default =
        let p = ../wallpapers + "/${config.custom.theme}.png"; in
        if builtins.pathExists p then p else ../wallpapers/gruvbox.png;
    };

    themeAuto = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      lightTime = lib.mkOption {
        type = lib.types.str;
        default = "06:30";
      };
      darkTime = lib.mkOption {
        type = lib.types.str;
        default = "18:30";
      };
    };
  };
}
