{ pkgs, ... }:
let
  devSetup = pkgs.writeShellApplication {
    name = "dev-setup";
    runtimeInputs = [ pkgs.fnm pkgs.nodejs pkgs.curl pkgs.bash pkgs.coreutils pkgs.unzip ];
    text = ''
      update=false
      if [[ "''${1:-}" == --update ]]; then
        update=true
        shift
      fi
      if [[ "''${1:-}" == --help || "''${1:-}" == -h ]]; then
        echo "Usage: dev-setup [node|bun|claude|codex|all ...]"
        echo "Installs only missing tools; defaults to all."
        echo "dev-update [tools ...] updates installed tools only."
        exit 0
      fi
      targets=("$@")
      if (( ''${#targets[@]} == 0 )) || [[ "''${targets[*]}" == all ]]; then
        targets=(node bun claude codex)
      fi
      for tool in "''${targets[@]}"; do
        case "$tool" in node|bun|claude|codex) ;; *) echo "Unknown tool: $tool" >&2; exit 2 ;; esac
      done

      installer=""
      failed=false
      trap '[[ -z "$installer" ]] || rm -f "$installer"' EXIT
      for tool in "''${targets[@]}"; do
        installed=false
        case "$tool" in
          node) if fnm exec --using default node --version >/dev/null 2>&1; then installed=true; fi ;;
          bun) if "$HOME/.bun/bin/bun" --version >/dev/null 2>&1; then installed=true; fi ;;
          claude) if "$HOME/.local/bin/claude" --version >/dev/null 2>&1; then installed=true; fi ;;
          codex) if node "$HOME/.local/share/ai-cli/lib/node_modules/@openai/codex/bin/codex.js" --version >/dev/null 2>&1; then installed=true; fi ;;
        esac
        if ! $update && $installed; then
          echo "$tool: already installed; skipped."
          continue
        fi
        if $update && ! $installed; then
          echo "$tool: not installed; skipped. Install with: dev-setup $tool"
          continue
        fi
        case "$tool" in
          node)
            if fnm install --lts; then
              fnm default lts-latest || failed=true
            else
              failed=true
            fi
            ;;
          bun)
            if $installed; then
              "$HOME/.bun/bin/bun" upgrade || failed=true
            else
              installer=$(mktemp)
              # Home Manager owns the shell files; let it supply the launchers.
              if curl -fsSL --retry 2 https://bun.com/install -o "$installer"; then
                env SHELL=none BUN_INSTALL="$HOME/.bun" bash "$installer" || failed=true
              else
                failed=true
              fi
              rm -f "$installer"
              installer=""
            fi
            ;;
          claude)
            if $installed; then
              "$HOME/.local/bin/claude" update || failed=true
            else
              installer=$(mktemp)
              if curl -fsSL --retry 2 https://claude.ai/install.sh -o "$installer"; then
                bash "$installer" latest || failed=true
              else
                failed=true
              fi
              rm -f "$installer"
              installer=""
            fi
            ;;
          codex)
            npm install --global --prefix "$HOME/.local/share/ai-cli" @openai/codex@latest || failed=true
            ;;
        esac
      done
      if $failed; then
        echo "Some tools failed; the other selected tools were still processed. Retry the failed tool by name." >&2
        exit 1
      fi
    '';
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
