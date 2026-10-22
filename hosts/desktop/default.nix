{ pkgs, ... }:
{
  imports = [
    ./hardware.nix

    ../common.nix

    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/zram.nix
    ../../modules/system/docker.nix
    ../../modules/system/mounts.nix
    ../../modules/system/envfs.nix
    ../../modules/system/appimage.nix

    ../../modules/gaming.nix

    ../../modules/hardware/gpu-amd.nix
    ../../modules/hardware/gpu-nvidia.nix

    ../../modules/desktop/plasma.nix
    ../../modules/desktop/audio.nix
    ../../modules/desktop/printing.nix
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/sunshine.nix
    ../../modules/desktop/virtual-machines.nix
  ];

  networking.hostName = "desktop";

  services.ratbagd.enable = true;
  environment.systemPackages = [ pkgs.piper ];
}
