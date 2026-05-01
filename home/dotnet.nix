{ pkgs, ... }:
let
  dotnet = pkgs.dotnet-sdk_10;
in
{
  home.packages = [ dotnet ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet}";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_NOLOGO = "1";
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
    DOTNET_GENERATE_ASPNET_CERTIFICATE = "0";
  };

  # Globally installed dotnet tools land here.
  home.sessionPath = [ "$HOME/.dotnet/tools" ];

  systemd.user.services.dotnet-cache-trim = {
    Unit.Description = "Trim .NET caches (entries older than 7 days)";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "dotnet-cache-trim" ''
        for dir in \
          "$HOME/.nuget/packages" \
          "$HOME/.local/share/NuGet/v3-cache" \
          "$HOME/.local/share/NuGet/plugins-cache" \
          "$HOME/.cache/NuGet" \
          "$HOME/.dotnet/tools/.store"; do
          [ -d "$dir" ] || continue
          ${pkgs.findutils}/bin/find "$dir" -type f -atime +7 -delete
          ${pkgs.findutils}/bin/find "$dir" -type d -empty -delete || true
        done
      '';
    };
  };

  systemd.user.timers.dotnet-cache-trim = {
    Unit.Description = "Trim .NET caches weekly";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
