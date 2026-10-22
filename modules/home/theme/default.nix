{ config, pkgs, lib, inputs, ... }:
let
  u = config.custom;

  # Build the six small theme bundles once; switching only selects a bundle.
  variants = lib.concatMap (theme: map (mode: { inherit theme mode; })
    [ "dark" "light" ]) [ "gruvbox" "rose-pine" "catppuccin" ];
  bundle = { theme, mode }:
    let
      themed = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.stylix.homeModules.stylix
          ../options.nix
          ./stylix.nix
          {
            home.username = config.home.username;
            home.homeDirectory = config.home.homeDirectory;
            home.stateVersion = config.home.stateVersion;
            custom = { inherit theme; colorScheme = mode; font = u.font; wallpaper = null; };
            stylix.autoEnable = false;
            stylix.targets.gtk.enable = true;
            stylix.targets.gtk.flatpakSupport.enable = false;
            stylix.targets.kde.enable = true;
            stylix.targets.zed.enable = true;
            programs.zed-editor.enable = true;
            stylix.targets.kde.useWallpaper = false;
            gtk.gtk3.colorScheme = mode;
            gtk.gtk4.colorScheme = mode;
            gtk.gtk3.extraConfig.gtk-enable-primary-paste = false;
            gtk.gtk4.extraConfig.gtk-enable-primary-paste = false;
          }
        ];
      };
      c = themed.config;
      kde = lib.findFirst (p: p.name == "stylix-kde-theme")
        (throw "KDE theme package missing") c.home.packages;
    in pkgs.runCommand "theme-${theme}-${mode}" {} ''
      mkdir -p "$out"
      cp ${c.xdg.configFile."gtk-3.0/gtk.css".source} "$out/gtk.css"
      cp ${c.xdg.configFile."gtk-3.0/settings.ini".source} "$out/gtk3.ini"
      cp ${c.xdg.configFile."gtk-4.0/settings.ini".source} "$out/gtk4.ini"
      cp ${kde}/share/color-schemes/*.colors "$out/desktop.colors"
      cp ${c.xdg.configFile."zed/themes/stylix.json".source} "$out/zed.json"
    '';
  bundles = pkgs.linkFarm "desktop-theme-bundles" (map (v: {
    name = "${v.theme}-${v.mode}";
    path = bundle v;
  }) variants);

  themeTool = pkgs.writeShellApplication {
    name = "dotfiles-theme";
    runtimeInputs = [ (pkgs.python3.withPackages (p: [ p.json5 ]))
      pkgs.glib pkgs.kdePackages.plasma-workspace ];
    text = ''
      exec python3 ${../../../scripts/theme.py} --assets ${bundles} \
        --wallpapers ${../../../assets/wallpapers} "$@"
    '';
  };
  themeSwitch = pkgs.writeShellApplication {
    name = "theme-switch";
    text = ''exec ${themeTool}/bin/dotfiles-theme mode "$@"'';
  };
  themeSet = pkgs.writeShellApplication {
    name = "theme-set";
    text = ''exec ${themeTool}/bin/dotfiles-theme theme "$@"'';
  };

  solarCheck = pkgs.writeShellApplication {
    name = "theme-solar-check";
    runtimeInputs = [ (pkgs.python3.withPackages (p: [ p.astral ])) ];
    text = ''
      exec python3 ${../../../scripts/theme-solar.py} \
        --latitude ${toString u.themeAuto.latitude} \
        --longitude ${toString u.themeAuto.longitude} \
        --timezone ${lib.escapeShellArg u.themeAuto.timeZone} \
        --switch ${themeSwitch}/bin/theme-switch "$@"
    '';
  };
  autoTimers = if u.themeAuto.mode == "solar" then "theme-solar.timer"
    else "theme-light.timer theme-dark.timer";

  themeAuto = pkgs.writeShellApplication {
    name = "theme-auto";
    runtimeInputs = [ pkgs.systemd pkgs.coreutils ];
    text = ''
      case "''${1:-status}" in
        on)
          rm -f "${config.xdg.configHome}/dotfiles/theme-auto-disabled"
          systemctl --user start ${autoTimers}
          ${lib.optionalString (u.themeAuto.mode == "solar") "${solarCheck}/bin/theme-solar-check --force"}
          ;;
        off)
          mkdir -p "${config.xdg.configHome}/dotfiles"
          touch "${config.xdg.configHome}/dotfiles/theme-auto-disabled"
          systemctl --user stop ${autoTimers}
          ;;
        status)
          ${if u.themeAuto.mode == "solar" then "${solarCheck}/bin/theme-solar-check --status" else ''
            if systemctl --user is-active --quiet ${autoTimers}; then
              echo "Auto theme: On"
            else
              echo "Auto theme: Off"
            fi
            echo "Light at:   ${u.themeAuto.lightTime}"
            echo "Dark at:    ${u.themeAuto.darkTime}"
          ''}
          ;;
        *) echo "usage: theme-auto on|off|status" >&2; exit 1 ;;
      esac
    '';
  };
in {
  imports = [ ./ghostty.nix ];

  home.packages = [ themeSwitch themeSet themeAuto pkgs.adw-gtk3 ];

  # Runtime owns these files. A stable indirection lets GTK read the active bundle.
  xdg.configFile = lib.genAttrs [ "gtk-3.0/gtk.css" "gtk-4.0/gtk.css"
    "gtk-3.0/settings.ini" "gtk-4.0/settings.ini" ] (name: {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.local/state/dotfiles-theme/current/${
          if lib.hasSuffix "gtk.css" name then "gtk.css"
          else if lib.hasPrefix "gtk-3" name then "gtk3.ini" else "gtk4.ini"}";
    }) // {
      "autostart/dotfiles-theme.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Apply desktop theme
        Exec=${themeTool}/bin/dotfiles-theme apply
        X-KDE-autostart-phase=2
      '';
    };
  home.activation.applyRuntimeTheme = lib.hm.dag.entryAfter
    [ "linkGeneration" "dconfSettings" "seedVscodeSettings" "zedSettingsActivation" "configure-plasma" ] ''
      run ${themeTool}/bin/dotfiles-theme apply
    '';

  systemd.user.services = lib.mkIf u.themeAuto.enable (if u.themeAuto.mode == "solar" then {
    theme-solar = {
      Unit.Description = "Switch theme at local sunrise and sunset";
      Service = {
        Type = "oneshot";
        ExecStart = "${solarCheck}/bin/theme-solar-check";
      };
    };
  } else {
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
  });

  systemd.user.timers = lib.mkIf u.themeAuto.enable (if u.themeAuto.mode == "solar" then {
    theme-solar = {
      Unit.Description = "Check local daylight every minute";
      Timer = {
        OnCalendar = "*-*-* *:*:00";
        OnStartupSec = "10s";
        AccuracySec = "1s";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  } else {
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
  });
}
