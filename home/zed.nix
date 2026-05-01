{ config, lib, ... }:
let
  fnmBin = "${config.home.homeDirectory}/.local/share/fnm/aliases/default/bin";
in {
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = true;

    extensions = [
      "catppuccin"
      "rose-pine-theme"
      "material-icon-theme"
      "nix"
      "go"
      "dockerfile"
      "docker-compose"
      "toml"
      "git-firefly"
      "html"
      "basher"
      "make"
      "env"
    ];

    userSettings = {
      buffer_font_size = lib.mkForce 17;
      ui_font_size = lib.mkForce 16;
      ui_font_family = lib.mkForce ".ZedSans";

      base_keymap = "VSCode";
      vim_mode = false;
      relative_line_numbers = "enabled";
      cursor_blink = false;
      format_on_save = "on";
      show_whitespaces = "selection";

      tab_bar.show = true;
      tabs.close_position = "right";
      scrollbar.show = "auto";

      icon_theme = "Material Icon Theme";
      project_panel.show_icons = true;

      languages.Go = {
        formatter = { external = { command = "goimports"; }; };
        format_on_save = "on";
        tab_size = 4;
        hard_tabs = true;
      };

      lsp.gopls.initialization_options = {
        usePlaceholders = true;
        completeUnimported = true;
        staticcheck = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      agent = {
        enabled = false;
        button = false;
      };
      features.edit_prediction_provider = "none";
      show_edit_predictions = false;

      agent_servers = {
        claude-acp = {
          type = "registry";
          env = {
            CLAUDE_CODE_EXECUTABLE = "${fnmBin}/claude";
          };
        };
      };
    };
  };
}
