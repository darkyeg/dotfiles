{ mkHome, ... }:
let
  userHome = ../../users/yoku/home.nix;
  full = mkHome [ ../../profiles/home/full.nix userHome ];
  username = full.config.home.username;
in
{
  "${username}@desktop" = full;
  "${username}@desktop-essential" = mkHome [
    ../../profiles/home/essential.nix
    userHome
  ];

  # Keep the original command target as an alias of the named configuration.
  inherit full;
}
