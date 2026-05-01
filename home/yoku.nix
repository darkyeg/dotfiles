{ ... }:
{
  imports = [
    ./options.nix
    ./stylix.nix
    ./theme.nix
    ./core.nix
    ./zsh.nix
    ./tmux.nix
    ./nvim.nix
    ./ghostty.nix
    ./git.nix
    ./go.nix
    ./rust.nix
    ./dotnet.nix
    ./zed.nix
    ./vscode.nix
    ./playwright.nix
    ./plasma.nix
    ./vesktop.nix
    ./spotify.nix
    ./walker.nix
    ./minecraft.nix
    ./packages/cli.nix
    ./packages/dev.nix
    ./packages/gui.nix
    ./packages/ai.nix
    ./packages/pdf.nix
  ];

  custom.themeAuto.enable = true;
  custom.font.mono = "JetBrainsMono Nerd Font";

  home.username = "yoku";
  home.homeDirectory = "/home/yoku";
  home.stateVersion = "25.11";
  home.sessionVariables.EDITOR = "nvim";

  programs.home-manager.enable = true;
}
