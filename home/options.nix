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
      mode = lib.mkOption {
        type = lib.types.enum [ "fixed" "solar" ];
        default = "fixed";
        description = "Use fixed clock times or local sunrise and sunset.";
      };
      latitude = lib.mkOption {
        type = lib.types.numbers.between (-90) 90;
        default = 30.0444;
        description = "Latitude used for sunrise and sunset (Cairo by default).";
      };
      longitude = lib.mkOption {
        type = lib.types.numbers.between (-180) 180;
        default = 31.2357;
        description = "Longitude used for sunrise and sunset (Cairo by default).";
      };
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Africa/Cairo";
        description = "Time zone for the solar schedule, including daylight saving time.";
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
