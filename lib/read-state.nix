{ lib }:
path: fallback:
let
  value = if builtins.pathExists path
    then lib.strings.trim (builtins.readFile path)
    else "";
in
if value == "" then fallback else value
