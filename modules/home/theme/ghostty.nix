{ config, ... }:
{
  programs.ghostty = {
    settings = {
      config-file = "?${config.home.homeDirectory}/.config/dotfiles/ghostty-theme";
      # Keep Ghostty's GTK header controls, including the new-tab button.
      window-decoration = "client";
      # Reload both the terminal palette and GTK toolbar colors together.
      window-theme = "ghostty";
      gtk-custom-css = "${config.home.homeDirectory}/.local/state/dotfiles-theme/current/gtk.css";
      shell-integration-features = "no-cursor,sudo,no-title";
      cursor-style = "block";
      adjust-cell-height = "35%";
      mouse-hide-while-typing = true;
      window-padding-balance = true;
      window-save-state = "always";
      background-opacity = 0.90;
      background-blur = true;
    };
  };
}
