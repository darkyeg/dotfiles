{ config, ... }:
{
  programs.vesktop = {
    enable = true;
    vencord.settings.enabledThemes = [ "dotfiles-fonts.css" ];
    vencord.themes.dotfiles-fonts = ''
      :root {
        --font-primary: "${config.custom.font.ui}", "Noto Sans", sans-serif;
        --font-display: "${config.custom.font.ui}", "Noto Sans", sans-serif;
        --font-headline: "${config.custom.font.ui}", "Noto Sans", sans-serif;
        --font-code: "${config.custom.font.mono}", monospace;
      }
    '';
    settings = {
      appBadge = false;
      arRPC = true;
      checkUpdates = false;
      tray = true;
      minimizeToTray = true;
    };
  };
}
