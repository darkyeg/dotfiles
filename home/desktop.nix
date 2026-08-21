{ ... }:
{
  imports = [
    ./profiles/base.nix
    ./stylix.nix
    ./theme.nix
    ./ghostty.nix
    ./zed.nix
    ./vscode.nix
    ./playwright.nix
    ./plasma.nix
    ./vesktop.nix
    ./spotify.nix
    ./walker.nix
    ./minecraft.nix
    ./packages/gui.nix
    ./packages/ai.nix
    ./packages/pdf.nix
  ];

  custom.themeAuto.enable = true;
  custom.font.mono = "JetBrainsMono Nerd Font";
}
