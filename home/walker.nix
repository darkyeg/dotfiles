{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system}.elephant-with-providers
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
    themes.default.style = ''
      /* Resolve colors from the active GTK theme, including runtime theme switches. */
      * {
        all: unset;
      }

      .box-wrapper {
        background: @window_bg_color;
        color: @window_fg_color;
        border: 1px solid alpha(@window_fg_color, 0.2);
        border-radius: 20px;
        padding: 20px;
        box-shadow: 0 12px 30px alpha(black, 0.25);
      }

      popover {
        background: @popover_bg_color;
        color: @popover_fg_color;
        border: 1px solid alpha(@window_fg_color, 0.2);
        border-radius: 12px;
        padding: 10px;
      }

      .normal-icons { -gtk-icon-size: 16px; }
      .large-icons { -gtk-icon-size: 32px; }
      .preview .large-icons { -gtk-icon-size: 64px; }
      scrollbar { opacity: 0; }

      .input {
        background: @view_bg_color;
        color: @view_fg_color;
        caret-color: @view_fg_color;
        border: 1px solid alpha(@window_fg_color, 0.2);
        border-radius: 10px;
        padding: 10px;
      }

      .input placeholder { opacity: 0.6; }
      .input selection {
        background: @accent_bg_color;
        color: @accent_fg_color;
      }

      .list, .preview-box, .elephant-hint, .placeholder, .keybinds {
        color: @window_fg_color;
      }

      .item-box { border-radius: 10px; padding: 10px; }
      child:selected .item-box, row:selected .item-box {
        background: alpha(@accent_bg_color, 0.18);
      }
      .item-quick-activation {
        background: alpha(@accent_bg_color, 0.18);
        border-radius: 5px;
        padding: 10px;
      }
      .item-subtext { font-size: 12px; opacity: 0.7; }
      .providerlist .item-subtext { font-size: inherit; }
      .item-image-text, .symbols .item-image { font-size: 28px; }
      .preview {
        border: 1px solid alpha(@window_fg_color, 0.2);
        border-radius: 10px;
        color: @window_fg_color;
      }
      .calc .item-text, .todo.urgent { font-size: 24px; }
      .todo.done .item-text-box, .bluetooth.disconnected { opacity: 0.5; }
      .todo.active { font-weight: bold; }
      .keybinds {
        padding-top: 10px;
        border-top: 1px solid alpha(@window_fg_color, 0.2);
        font-size: 12px;
      }
      .keybind-button { opacity: 0.7; }
      .keybind-button:hover { opacity: 1; }
      .keybind-bind { text-transform: lowercase; opacity: 0.7; }
      .keybind-label {
        padding: 2px 4px;
        border-radius: 4px;
        border: 1px solid alpha(@window_fg_color, 0.5);
      }
      .error { padding: 10px; background: @error_bg_color; color: @error_fg_color; }
      :not(.calc).current { font-style: italic; }
      .preview-content.archlinuxpkgs, .preview-content.dnfpackages { font-family: monospace; }
    '';
  };
}
