{ config, ... }:
{
  home.sessionVariables.TERMINAL = "ghostty";

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };

  programs.ghostty = {
    enable = true;
    settings = {
      # Avoid inflated I/O-wait reporting with io_uring.
      async-backend = "epoll";
      font-family = config.custom.font.mono;
      font-size = 13;
    };
  };
}
