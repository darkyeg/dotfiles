{ pkgs, ... }:
{
  imports = [ ./runtime.nix ];

  # Keep a browser and terminal available before Home Manager finishes.
  environment.systemPackages = with pkgs; [ brave ghostty git curl unzip ];
}
