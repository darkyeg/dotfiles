{ pkgs, ... }:
{
  imports = [ ./system/runtime.nix ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];
}
