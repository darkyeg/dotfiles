{ pkgs, ... }:
{
  gtk.enable = true;
  gtk.theme = { name = "adw-gtk3-dark"; package = pkgs.adw-gtk3; };
  gtk.gtk4.theme = null;
  gtk.gtk4.extraCss = ''
    @define-color window_bg_color @theme_bg_color;
    @define-color window_fg_color @theme_fg_color;
    @define-color view_bg_color @theme_base_color;
    @define-color view_fg_color @theme_text_color;
    @define-color accent_bg_color @theme_selected_bg_color;
    @define-color accent_fg_color @theme_selected_fg_color;
    @define-color popover_bg_color @theme_bg_color;
    @define-color popover_fg_color @theme_fg_color;
    @define-color error_bg_color #b3261e;
    @define-color error_fg_color #ffffff;
  '';
}
