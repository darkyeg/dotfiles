{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  # Keep a browser and terminal available before Home Manager finishes.
  environment.systemPackages = with pkgs; [ brave ghostty git curl unzip ];
}
