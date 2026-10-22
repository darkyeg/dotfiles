{ config, ... }:
let
  walkerCommand = "${config.programs.walker.package}/bin/walker";
in
{
  # Plasma caches this path; keep it linked to the managed launcher entry.
  xdg.desktopEntries.plasma-manager-commands.exec = walkerCommand;
  xdg.dataFile."applications/plasma-manager-commands.desktop".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.profileDirectory}/share/applications/plasma-manager-commands.desktop";

  programs.plasma = {
    enable = true;

    kwin = {
      virtualDesktops.number = 4;
      effects.blur.enable = true;
    };

    configFile = {
      kdeglobals.General = {
        BrowserApplication = "brave-browser.desktop";
        TerminalApplication = "ghostty";
        TerminalService = "com.mitchellh.ghostty.desktop";
        font = "${config.custom.font.ui},12,-1,5,50,0,0,0,0,0";
        fixed = "${config.custom.font.mono},13,-1,5,50,0,0,0,0,0";
        menuFont = "${config.custom.font.ui},11,-1,5,50,0,0,0,0,0";
      };
      kwinrc."TabBox".LayoutName = "informative";
      kwinrc."TabBox".HighlightWindows = false;
      kwinrc."TabBox".DelayTime = 0;
      kwinrc."Plugins".slideEnabled = false;
      kwinrc."Plugins".fadeEnabled = false;
    };

    shortcuts."org.kde.krunner.desktop"."_launch" = [ "Alt+F2" "Alt+Shift+F2" ];
    shortcuts."services/com.mitchellh.ghostty.desktop"."_launch" = "Ctrl+Alt+T";
    shortcuts."services/org.kde.konsole.desktop"."_launch" = [];

    shortcuts.kwin = {
      "Switch to Desktop 1" = "Ctrl+Alt+1";
      "Switch to Desktop 2" = "Ctrl+Alt+2";
      "Switch to Desktop 3" = "Ctrl+Alt+3";
      "Switch to Desktop 4" = "Ctrl+Alt+4";

      "Window to Desktop 1" = "Ctrl+Alt+Shift+1";
      "Window to Desktop 2" = "Ctrl+Alt+Shift+2";
      "Window to Desktop 3" = "Ctrl+Alt+Shift+3";
      "Window to Desktop 4" = "Ctrl+Alt+Shift+4";

      "Switch One Desktop to the Left"  = "Ctrl+Alt+Left";
      "Switch One Desktop to the Right" = "Ctrl+Alt+Right";

      "Window One Desktop to the Left"  = "Ctrl+Alt+Shift+Left";
      "Window One Desktop to the Right" = "Ctrl+Alt+Shift+Right";
    };

    hotkeys.commands.launch-walker = {
      name = "Walker";
      key = "Alt+Space";
      command = walkerCommand;
      logs.enabled = false;
    };
  };
}
