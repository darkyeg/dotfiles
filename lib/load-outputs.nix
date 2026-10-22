{ lib }:
directory: load:
let
  entries = builtins.readDir directory;
  files = lib.filterAttrs (name: kind:
    kind == "regular" && lib.hasSuffix ".nix" name
  ) entries;
  definitions = map (name:
    let
      path = directory + "/${name}";
      values = load path;
    in
    if builtins.isAttrs values then values
    else throw "Expected named outputs from ${toString path}."
  ) (builtins.attrNames files);
in
lib.zipAttrsWith (name: values:
  if builtins.length values == 1 then builtins.head values
  else throw "Duplicate output '${name}' in ${toString directory}."
) definitions
