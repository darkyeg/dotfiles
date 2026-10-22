{ mkHome, ... }:
{
  essential = mkHome [
    ../../profiles/home/essential.nix
    ../../users/current.nix
  ];
}
