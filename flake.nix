{
  description = "yoku's NixOS + home-manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Security fixes can reach master before the nixos-unstable channel.
    nixpkgs-tailscale.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, stylix, spicetify-nix, walker, fenix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # Reuse the installer's channel for the small first system rebuild.
      # Flake-only machines fall back to this repository's pinned nixpkgs.
      installedChannel = "/nix/var/nix/profiles/per-user/root/channels/nixos";
      bootstrapSource = if builtins.pathExists "${installedChannel}/nixos/lib/eval-config.nix"
        then builtins.toPath installedChannel else nixpkgs.outPath;
    in {
      nixosConfigurations.bootstrap = import (bootstrapSource + "/nixos/lib/eval-config.nix") {
        inherit system;
        modules = [
          /etc/nixos/configuration.nix
          ./modules/system/bootstrap.nix
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/desktop ];
      };

      homeConfigurations."yoku@desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          plasma-manager.homeModules.plasma-manager
          stylix.homeModules.stylix
          spicetify-nix.homeManagerModules.default
          walker.homeManagerModules.default
          ./home/yoku.nix
        ];
      };

      homeConfigurations.full = self.homeConfigurations."yoku@desktop";
      homeConfigurations.essential = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          plasma-manager.homeModules.plasma-manager
          walker.homeManagerModules.default
          ./home/essential.nix
        ];
      };
    };
}
