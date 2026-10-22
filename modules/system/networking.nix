{ inputs, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
  networking.firewall.enable = true;
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8317 ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    package = inputs.nixpkgs-tailscale.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tailscale;
  };
}
