{ inputs, nixpkgs, system, ... }:
{
  desktop = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ ../../hosts/desktop ];
  };
}
