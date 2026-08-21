{ lib, ... }:
{
  imports = [ ./profiles/base.nix ];

  programs.zsh.initContent = lib.mkAfter ''
    if [[ -x /usr/lib/wsl/lib/nvidia-smi ]]; then
      nvidia-smi() {
        LD_LIBRARY_PATH=/run/opengl-driver/lib \
          /usr/lib/wsl/lib/nvidia-smi "$@"
      }
    fi
  '';
}
