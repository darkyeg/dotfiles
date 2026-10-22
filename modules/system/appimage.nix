{ pkgs, lib, ... }:
let
  gtkArgs = "\${gappsWrapperArgs[@]}";
  gearlever = pkgs.gearlever.overrideAttrs (old: lib.optionalAttrs
    (lib.elem gtkArgs (old.makeWrapperArgs or [])) {
    # Expand GTK's array in the build shell and pass individual wrapper arguments.
    makeWrapperArgs = lib.concatMap (lib.splitString " ")
      (lib.filter (arg: arg != gtkArgs) old.makeWrapperArgs);
    preFixup = (old.preFixup or "") + ''
      makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';
  });
in {
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [ gearlever ];
}
