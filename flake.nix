{
  description = "darky's NixOS + home-manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
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

  outputs = { self, nixpkgs, home-manager, nixos-wsl, plasma-manager, stylix, spicetify-nix, walker, fenix, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "darky";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [ ./hosts/desktop ];
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/wsl
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs username;
              includeRustDocs = false;
            };
            home-manager.users.${username} = import ./home/wsl.nix;
          }
        ];
      };

      homeConfigurations."${username}@desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs username;
          includeRustDocs = true;
        };
        modules = [
          plasma-manager.homeModules.plasma-manager
          stylix.homeModules.stylix
          spicetify-nix.homeManagerModules.default
          walker.homeManagerModules.default
          ./home/desktop.nix
        ];
      };

      devShells.${system}.cuda-python =
        let
          cuda = pkgs.cudaPackages_12_6;
        in (pkgs.mkShell.override {
          stdenv = cuda.backendStdenv;
        }) {
          packages = [
            pkgs.uv
            pkgs.pkg-config
            pkgs.libffi
            cuda.cudatoolkit
          ];

          CUDA_HOME = "${cuda.cudatoolkit}";
          CUDA_PATH = "${cuda.cudatoolkit}";
          UV_PROJECT_ENVIRONMENT = ".venv";
          UV_PYTHON = "3.10";

          shellHook = ''
            export LD_LIBRARY_PATH="/run/opengl-driver/lib:${cuda.cudatoolkit}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export PATH="$PWD/.venv/bin:$PATH"
          '';
        };
    };
}
