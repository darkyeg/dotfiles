{ ... }:
{
  programs.plasma = {
    enable = true;

    kwin = {
      virtualDesktops.number = 4;
      effects.blur.enable = true;
    };

    configFile = {
      kwinrc."TabBox".LayoutName = "informative";
      kwinrc."TabBox".HighlightWindows = false;
      kwinrc."TabBox".DelayTime = 0;
      kwinrc."Plugins".slideEnabled = false;
      kwinrc."Plugins".fadeEnabled = false;
    };

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
      # Ctrl+Space clashes with the KDE / ibus input-method switcher and
      # with IDE autocomplete on VS Code / JetBrains. Meta (Super) + Space
      # matches the Spotlight / GNOME-Activities convention most users
      # already have muscle memory for and is unbound on stock Plasma.
      key = "Meta+Space";
      command = "walker";
    };
  };
}
