{ inputs, pkgs }:
modules:
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs; };
  modules = [
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.stylix.homeModules.stylix
    inputs.spicetify-nix.homeManagerModules.default
    inputs.walker.homeManagerModules.default
  ] ++ modules;
}
