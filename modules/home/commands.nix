{ config, lib, pkgs, ... }:
let
  readState = import ../../lib/read-state.nix { inherit lib; };
  repositoryOverride = builtins.getEnv "DOTFILES";
  savedRepository = readState "${config.xdg.configHome}/dotfiles/repository"
    "${config.home.homeDirectory}/dotfiles";
  repository = if repositoryOverride == "" then savedRepository else repositoryOverride;

  dotfilesTool = pkgs.writeShellApplication {
    name = "dotfiles";
    runtimeInputs = [ pkgs.nh pkgs.coreutils pkgs.bash ];
    text = builtins.readFile ../../scripts/dotfiles;
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
in
{
  programs.nh = {
    enable = true;
    flake = lib.mkDefault repository;
  };

  home.packages = [ dotfilesTool ] ++ shortcuts;
}
