{ pkgs, inputs, ... }:
let
  fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
  toolchain = fenix.stable.withComponents [
    "cargo"
    "rustc"
    "clippy"
    "rustfmt"
    "rust-src"
    "rust-std"
    "rust-docs"
  ];
in
{
  home.packages = [
    toolchain
    fenix.rust-analyzer
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  systemd.user.services.cargo-cache-trim = {
    Unit.Description = "Trim cargo registry cache (entries older than 7 days)";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "cargo-cache-trim" ''
        for dir in "$HOME/.cargo/registry/cache" "$HOME/.cargo/registry/src" "$HOME/.cargo/git/checkouts"; do
          [ -d "$dir" ] || continue
          ${pkgs.findutils}/bin/find "$dir" -type f -atime +7 -delete
          ${pkgs.findutils}/bin/find "$dir" -type d -empty -delete || true
        done
      '';
    };
  };

  systemd.user.timers.cargo-cache-trim = {
    Unit.Description = "Trim cargo registry cache weekly";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
