{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.elephant.packages.${pkgs.system}.elephant-with-providers
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };
}
