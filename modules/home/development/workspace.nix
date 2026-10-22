{ lib, ... }:
{
  home.activation.createWorkspaceFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p \
      "$HOME/Workspace/work" \
      "$HOME/Workspace/personal" \
      "$HOME/Workspace/learning" \
      "$HOME/Workspace/playground"
  '';
}
