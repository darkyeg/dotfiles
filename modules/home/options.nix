{ config, lib, ... }:
let
  stateDir = "${config.home.homeDirectory}/.config/dotfiles";
  readFile = import ../../lib/read-state.nix { inherit lib; };
  readState = name: default:
    readFile "${stateDir}/${name}" default;
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
        let p = ../../assets/wallpapers + "/${config.custom.theme}.png"; in
        if builtins.pathExists p then p else ../../assets/wallpapers/gruvbox.png;
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
        default = 0;
        description = "Latitude used for sunrise and sunset; set it in the user's home module.";
      };
      longitude = lib.mkOption {
        type = lib.types.numbers.between (-180) 180;
        default = 0;
        description = "Longitude used for sunrise and sunset; set it in the user's home module.";
      };
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "UTC";
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
