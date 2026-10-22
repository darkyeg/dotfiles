{ pkgs, ... }:
let
  devSetup = pkgs.writeShellApplication {
    name = "dev-setup";
    runtimeInputs = [ pkgs.fnm pkgs.nodejs pkgs.curl pkgs.bash pkgs.coreutils pkgs.unzip ];
    text = builtins.readFile ../../../scripts/dev-setup;
  };
  devUpdate = pkgs.writeShellApplication {
    name = "dev-update";
    text = ''exec ${devSetup}/bin/dev-setup --update "$@"'';
  };
  bun = pkgs.writeShellApplication {
    name = "bun";
    text = ''
      if [[ ! -x "$HOME/.bun/bin/bun" ]]; then
        echo "Bun is not installed yet. Run dev-setup bun." >&2
        exit 1
      fi
      exec "$HOME/.bun/bin/bun" "$@"
    '';
  };
  bunx = pkgs.writeShellApplication {
    name = "bunx";
    text = ''exec ${bun}/bin/bun x "$@"'';
  };
  codex = pkgs.writeShellApplication {
    name = "codex";
    runtimeInputs = [ pkgs.nodejs pkgs.ripgrep ];
    text = ''
      cli="$HOME/.local/share/ai-cli/lib/node_modules/@openai/codex/bin/codex.js"
      if [[ ! -f "$cli" ]]; then
        echo "Codex is not installed yet. Run dev-setup codex." >&2
        exit 1
      fi
      exec node "$cli" "$@"
    '';
  };
  aiUpdate = pkgs.writeShellApplication {
    name = "ai-update";
    text = ''exec ${devSetup}/bin/dev-setup --update claude codex'';
  };
in {
  # Nix owns the runtime and launchers; upstream owns the CLI versions.
  home.packages = [
    codex
    bun
    bunx
    devSetup
    devUpdate
    aiUpdate
    pkgs.ripgrep
    pkgs.bubblewrap
    pkgs.socat
  ];
}
