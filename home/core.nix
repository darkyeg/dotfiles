{ config, lib, pkgs, ... }:
let
  dotfilesTool = pkgs.writeShellApplication {
    name = "dotfiles";
    runtimeInputs = [ pkgs.nh pkgs.coreutils pkgs.bash ];
    text = builtins.readFile ./scripts/dotfiles;
  };
  shortcuts = lib.mapAttrsToList (name: action:
    pkgs.writeShellScriptBin name ''exec ${dotfilesTool}/bin/dotfiles ${action} "$@"''
  ) {
    hm = "home";
    hmu = "home-update";
    os = "system";
    osu = "system-update";
    update-all = "update-all";
  };
in {
  gtk.gtk3.extraConfig.gtk-enable-primary-paste = false;
  gtk.gtk4.extraConfig.gtk-enable-primary-paste = false;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/dotfiles";
  };

  home.packages = [ dotfilesTool ] ++ shortcuts;

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
}
