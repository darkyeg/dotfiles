{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    deno
    python3
    uv
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
