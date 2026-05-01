{ ... }:
let
  ntfsOpts = [
    "defaults"
    "uid=1000"
    "gid=100"
    "umask=0022"
    "nofail"
    "x-systemd.automount"
    "noauto"
  ];
in {
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/c" = {
    device = "/dev/disk/by-uuid/86F2CD88F2CD7D45";
    fsType = "ntfs3";
    options = ntfsOpts;
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/01DB3515B37CD690";
    fsType = "ntfs3";
    options = ntfsOpts;
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/01D90113E347CC00";
    fsType = "ntfs3";
    options = ntfsOpts;
  };
}
