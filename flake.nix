{
  description = "NixOS and Home Manager configurations";

  # Inputs must be static; host and user composition lives in configurations.nix.
  inputs = {
    # Core configuration.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Desktop configuration and themes.
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # App integrations.
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    elephant.url = "github:abenz1267/elephant";
    walker.url = "github:abenz1267/walker";
    walker.inputs.elephant.follows = "elephant";

    # Rust toolchains.
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # Tailscale security fixes can reach master before nixos-unstable.
    nixpkgs-tailscale.url = "github:NixOS/nixpkgs/master";
  };

  outputs = inputs: import ./configurations.nix inputs;
}
