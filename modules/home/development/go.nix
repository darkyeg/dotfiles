{ pkgs, ... }:
{
  programs.go.enable = true;

  systemd.user.services.go-cache-trim = {
    Unit.Description = "Trim Go build cache (entries older than 3 days)";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "go-cache-trim" ''
        cache="$HOME/.cache/go-build"
        [ -d "$cache" ] || exit 0
        ${pkgs.findutils}/bin/find "$cache" -type f -atime +3 -delete
        ${pkgs.findutils}/bin/find "$cache" -type d -empty -delete || true
      '';
    };
  };

  systemd.user.timers.go-cache-trim = {
    Unit.Description = "Trim Go build cache weekly";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
