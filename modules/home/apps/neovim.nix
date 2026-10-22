{ config, ... }:
{
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.programs.nh.flake}/config/nvim";
}
