{ ... }:
{
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
  networking.firewall.enable = true;
}
