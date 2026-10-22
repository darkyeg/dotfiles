{ pkgs, ... }:
{
  imports = [
    ./hardware.nix

    ../../modules/nixos/base.nix
    ../../users/yoku/nixos.nix
    ./storage.nix

    ../../modules/nixos/system/boot.nix
    ../../modules/nixos/system/networking.nix
    ../../modules/nixos/system/zram.nix
    ../../modules/nixos/system/docker.nix
    ../../modules/nixos/system/envfs.nix
    ../../modules/nixos/system/appimage.nix

    ../../modules/nixos/gaming.nix

    ../../modules/nixos/hardware/gpu-amd.nix
    ../../modules/nixos/hardware/gpu-nvidia.nix

    ../../modules/nixos/desktop/plasma.nix
    ../../modules/nixos/desktop/audio.nix
    ../../modules/nixos/desktop/printing.nix
    ../../modules/nixos/desktop/fonts.nix
    ../../modules/nixos/desktop/sunshine.nix
    ../../modules/nixos/desktop/virtual-machines.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "26.05";

  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  console.keyMap = "us";

  services.ratbagd.enable = true;
  environment.systemPackages = [ pkgs.piper ];
}
