{ config, lib, pkgs, ... }:
let
  themeMap = {
    gruvbox = { dark = "Gruvbox Dark Hard"; light = "Gruvbox Light Hard"; };
    rose-pine = { dark = "Rosé Pine"; light = "Rosé Pine Dawn"; };
    catppuccin = { dark = "Catppuccin Mocha"; light = "Catppuccin Latte"; };
  };
  picked = themeMap.${config.custom.theme};
  colorTheme = if config.custom.colorScheme == "light" then picked.light else picked.dark;

  defaultSettings = {
    "editor.fontFamily" = "'${config.custom.font.mono}', monospace";
    "editor.fontSize" = 15;
    "editor.fontLigatures" = true;
    "editor.lineHeight" = 1.6;
    "editor.cursorBlinking" = "solid";
    "editor.smoothScrolling" = true;
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.mouseWheelScrollSensitivity" = 1;
    "workbench.list.smoothScrolling" = true;
    "terminal.integrated.smoothScrolling" = true;
    "editor.minimap.enabled" = false;
    "editor.renderWhitespace" = "selection";
    "editor.bracketPairColorization.enabled" = true;
    "editor.guides.bracketPairs" = "active";
    "editor.stickyScroll.enabled" = true;
    "editor.formatOnSave" = true;
    "editor.codeActionsOnSave" = {
      "source.organizeImports" = "explicit";
      "source.fixAll" = "explicit";
    };
    "editor.tabSize" = 2;
    "editor.wordWrap" = "on";

    "terminal.integrated.fontFamily" = "'${config.custom.font.mono}'";
    "terminal.integrated.fontSize" = 14;
    "terminal.integrated.defaultProfile.linux" = "zsh";

    "window.zoomLevel" = 1;

    "workbench.colorTheme" = colorTheme;
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.startupEditor" = "none";
    "workbench.editor.enablePreview" = false;
    "workbench.tree.indent" = 16;
    "workbench.editor.limit.enabled" = true;
    "workbench.editor.limit.value" = 10;

    "files.autoSave" = "onFocusChange";
    "files.trimTrailingWhitespace" = true;
    "files.insertFinalNewline" = true;
    "files.exclude" = {
      "**/.git" = true;
      "**/node_modules" = true;
      "**/.direnv" = true;
      "**/result" = true;
    };

    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;

    "git.autofetch" = true;
    "git.confirmSync" = false;
    "git.enableSmartCommit" = true;

    "telemetry.telemetryLevel" = "off";
    "update.mode" = "none";
    "extensions.autoCheckUpdates" = false;
    "extensions.autoUpdate" = false;

    "security.workspace.trust.enabled" = false;

    "errorLens.enabled" = true;

    "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.formatterPath" = "nixfmt";

    "[go]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = false;
      "editor.defaultFormatter" = "golang.go";
    };
    "go.useLanguageServer" = true;
    "go.formatTool" = "goimports";
    "go.lintTool" = "staticcheck";
    "go.toolsManagement.autoUpdate" = false;

    "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
    "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";
  };

  seedFile = pkgs.writeText "vscode-settings-seed.json"
    (builtins.toJSON defaultSettings);
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        golang.go
        rust-lang.rust-analyzer
        ms-python.python
        ms-azuretools.vscode-docker
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        editorconfig.editorconfig
        tamasfe.even-better-toml
        redhat.vscode-yaml
        eamodio.gitlens
        mhutchie.git-graph
        pkief.material-icon-theme
        usernamehw.errorlens
        christian-kohler.path-intellisense
        streetsidesoftware.code-spell-checker
        bradlc.vscode-tailwindcss
        ms-vscode.makefile-tools
        naumovs.color-highlight
        oderwat.indent-rainbow
        jdinhlife.gruvbox
        catppuccin.catppuccin-vsc
        mvllow.rose-pine
        ms-vscode.cpptools
        ms-vscode.cmake-tools
        twxs.cmake
      ];

      keybindings = [
        { key = "ctrl+k ctrl+t"; command = "workbench.action.selectTheme"; }
        { key = "ctrl+p"; command = "workbench.action.quickOpen"; }
        { key = "ctrl+shift+p"; command = "workbench.action.showCommands"; }
        { key = "ctrl+`"; command = "workbench.action.terminal.toggleTerminal"; }
        { key = "ctrl+b"; command = "workbench.action.toggleSidebarVisibility"; }
        { key = "alt+up"; command = "editor.action.moveLinesUpAction"; when = "editorTextFocus && !editorReadonly"; }
        { key = "alt+down"; command = "editor.action.moveLinesDownAction"; when = "editorTextFocus && !editorReadonly"; }
      ];
    };
  };

  home.activation.seedVscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/Code/User/settings.json"
    if [ ! -e "$target" ]; then
      mkdir -p "$(dirname "$target")"
      cp ${seedFile} "$target"
      chmod u+w "$target"
    fi
  '';

  home.activation.refreshKdeMenu = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if command -v kbuildsycoca6 >/dev/null 2>&1; then
      $DRY_RUN_CMD kbuildsycoca6 --noincremental || true
    fi
  '';
}
