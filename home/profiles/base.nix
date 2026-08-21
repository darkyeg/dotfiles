{ username, ... }:
{
  imports = [
    ../options.nix
    ../core.nix
    ../zsh.nix
    ../tmux.nix
    ../nvim.nix
    ../git.nix
    ../go.nix
    ../rust.nix
    ../dotnet.nix
    ../packages/cli.nix
    ../packages/dev.nix
  ];

  custom.theme = "gruvbox";

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";
  home.sessionVariables.EDITOR = "nvim";

  programs.home-manager.enable = true;
}
