{ pkgs, lib, ... }:
{
  programs.go.enable = true;

  home.packages = with pkgs; [
    neovim
    fnm
    deno
    python3
    gcc
    gnumake
    lua-language-server
    nil
    gopls
    (lib.hiPrio gotools)
    delve
    lazygit
    lazydocker
    docker-compose
  ];
}
