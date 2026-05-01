{ ... }:
{
  programs.vesktop = {
    enable = true;
    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      tray = true;
      minimizeToTray = true;
    };
  };
}
