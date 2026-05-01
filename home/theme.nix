{ config, pkgs, lib, ... }:
let
  u = config.custom;
  flakeDir = "${config.home.homeDirectory}/dotfiles";
  stateDir = "${config.home.homeDirectory}/.config/dotfiles";

  writeState = pkgs.writeShellApplication {
    name = "dotfiles-write-state";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      mkdir -p "${stateDir}"
      printf '%s' "$2" > "${stateDir}/$1"
    '';
  };

  refreshPlasma = pkgs.writeShellApplication {
    name = "refresh-plasma";
    runtimeInputs = [ pkgs.coreutils pkgs.kdePackages.plasma-workspace ];
    text = ''
      theme=$(cat "${stateDir}/theme" 2>/dev/null || echo gruvbox)
      wp="${flakeDir}/wallpapers/$theme.png"
      [ -f "$wp" ] || wp="${flakeDir}/wallpapers/gruvbox.png"
      plasma-apply-wallpaperimage "$wp" 2>/dev/null || true
    '';
  };

  themeSwitch = pkgs.writeShellApplication {
    name = "theme-switch";
    runtimeInputs = [ pkgs.coreutils pkgs.nh ];
    text = ''
      mode="''${1:-}"
      current=$(cat "${stateDir}/colorScheme" 2>/dev/null || echo dark)
      case "$mode" in
        dark|light) ;;
        toggle) [ "$current" = dark ] && mode=light || mode=dark ;;
        *) echo "usage: theme-switch dark|light|toggle" >&2; exit 1 ;;
      esac
      ${writeState}/bin/dotfiles-write-state colorScheme "$mode"
      cd "${flakeDir}" && nh home switch -- --impure
      ${refreshPlasma}/bin/refresh-plasma
    '';
  };

  themeSet = pkgs.writeShellApplication {
    name = "theme-set";
    runtimeInputs = [ pkgs.coreutils pkgs.nh ];
    text = ''
      name="''${1:-}"
      case "$name" in
        gruvbox|rose-pine|catppuccin) ;;
        *) echo "usage: theme-set gruvbox|rose-pine|catppuccin" >&2; exit 1 ;;
      esac
      ${writeState}/bin/dotfiles-write-state theme "$name"
      cd "${flakeDir}" && nh home switch -- --impure
      ${refreshPlasma}/bin/refresh-plasma
    '';
  };

  themeAuto = pkgs.writeShellApplication {
    name = "theme-auto";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      case "''${1:-status}" in
        on)     systemctl --user start  theme-light.timer theme-dark.timer ;;
        off)    systemctl --user stop   theme-light.timer theme-dark.timer ;;
        status) systemctl --user list-timers 'theme-*.timer' --no-pager ;;
        *) echo "usage: theme-auto on|off|status" >&2; exit 1 ;;
      esac
    '';
  };
in {
  home.packages = [ themeSwitch themeSet themeAuto ];

  systemd.user.services = lib.mkIf u.themeAuto.enable {
    theme-light = {
      Unit.Description = "Switch theme to light";
      Service = {
        Type = "oneshot";
        ExecStart = "${themeSwitch}/bin/theme-switch light";
      };
    };
    theme-dark = {
      Unit.Description = "Switch theme to dark";
      Service = {
        Type = "oneshot";
        ExecStart = "${themeSwitch}/bin/theme-switch dark";
      };
    };
  };

  systemd.user.timers = lib.mkIf u.themeAuto.enable {
    theme-light = {
      Unit.Description = "Morning light theme";
      Timer = {
        OnCalendar = "*-*-* ${u.themeAuto.lightTime}:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
    theme-dark = {
      Unit.Description = "Evening dark theme";
      Timer = {
        OnCalendar = "*-*-* ${u.themeAuto.darkTime}:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
