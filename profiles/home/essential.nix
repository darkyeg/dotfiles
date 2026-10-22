{ lib, pkgs, ... }:
{
  imports = [
    ./base.nix
    ../../modules/home/desktop/plasma.nix
    ../../modules/home/desktop/walker.nix
    ../../modules/home/theme/essential.nix
  ];

  # The installer's account may still use Bash as its login shell.
  programs.ghostty.settings.command = "${pkgs.zsh}/bin/zsh";
  programs.git.settings.commit.gpgsign = lib.mkForce false;
  programs.git.settings.tag.gpgsign = lib.mkForce false;
}
