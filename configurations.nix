{ nixpkgs, ... }@inputs:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  mkHome = import ./lib/mk-home.nix { inherit inputs pkgs; };
  loadOutputs = import ./lib/load-outputs.nix { inherit (nixpkgs) lib; };
  context = { inherit inputs nixpkgs system pkgs mkHome; };
  loadConfiguration = path: import path context;
in
{
  nixosConfigurations = loadOutputs ./configurations/nixos loadConfiguration;
  homeConfigurations = loadOutputs ./configurations/home loadConfiguration;
  packages.${system} = loadOutputs ./packages (path: {
    ${nixpkgs.lib.removeSuffix ".nix" (builtins.baseNameOf path)} = pkgs.callPackage path {};
  });
}
