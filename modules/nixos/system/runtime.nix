{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
}
