{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [
        temurin-bin-21
        temurin-bin-17
        temurin-bin-8
      ];
    })
  ];

  home.sessionVariables.__GL_THREADED_OPTIMIZATIONS = "0";
}
