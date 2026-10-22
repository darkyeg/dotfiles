#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
profile=essential
with_system=true
dry=false
tools=(node bun claude codex)
usage() {
  cat <<'HELP'
Usage: bash bootstrap.sh [options]
  --full            Install the full Home Manager setup instead of essentials
  --home-only       Keep the current NixOS configuration unchanged
  --tools LIST      Comma-separated tools: node,bun,claude,codex
  --no-tools        Install only the Nix-managed apps and shell configuration
  --dry-run         Print the steps without applying or downloading anything

Default: add browser/runtime support to the existing NixOS configuration,
apply the essentials profile, then install missing dev tools. Rerun to resume.
HELP
}
while (( $# )); do
  case "$1" in
    --full) profile=full ;;
    --home-only) with_system=false ;;
    --no-tools) tools=() ;;
    --dry-run) dry=true ;;
    --tools)
      if (( $# < 2 )) || [[ -z "$2" ]]; then echo "--tools needs a comma-separated list." >&2; exit 2; fi
      IFS=, read -r -a tools <<< "$2"
      shift
      ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
for tool in "${tools[@]}"; do
  case "$tool" in node|bun|claude|codex) ;; *) echo "Unknown tool: $tool" >&2; exit 2 ;; esac
done
if (( EUID == 0 )); then echo "Run as your normal user; the system step uses sudo." >&2; exit 1; fi
if [[ ! -e /etc/NIXOS ]]; then echo "This bootstrap is for an installed NixOS desktop." >&2; exit 1; fi
if $with_system && [[ ! -f /etc/nixos/configuration.nix ]]; then
  echo "Missing /etc/nixos/configuration.nix. Use --home-only if this machine already uses another flake." >&2
  exit 1
fi
command -v nix >/dev/null || { echo "Nix is required." >&2; exit 1; }
export DOTFILES="$repo"

run() {
  if $dry; then printf '  '; printf '%q ' "$@"; printf '\n'; else "$@"; fi
}
nix_cmd() { nix --extra-experimental-features 'nix-command flakes' "$@"; }
state="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
if ! $dry; then
  logs="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
  mkdir -p "$logs"
  exec > >(tee -a "$logs/bootstrap.log") 2>&1
  trap 'echo "Setup stopped. Rerun the same command to resume. Log: $logs/bootstrap.log" >&2' ERR
fi

echo "1/3: Browser and NixOS runtime support"
if $with_system; then
  # This imports the installer-created configuration, including its hardware.
  run sudo nixos-rebuild switch --flake "$repo#bootstrap" --impure \
    --option experimental-features 'nix-command flakes'
  if ! $dry; then
    mkdir -p "$state"
    printf 'essential\n' > "$state/system-profile"
  fi
else
  echo "  Keeping the current system configuration."
fi

echo "2/3: $profile Home Manager profile"
if $dry; then
  run nix --extra-experimental-features 'nix-command flakes' build \
    "$repo#homeConfigurations.$profile.activationPackage" --impure --no-link --print-out-paths
  echo "  Activate that Home Manager generation and remember this checkout/profile."
else
  expected_user=$(nix_cmd eval --raw "$repo#homeConfigurations.$profile.config.home.username" --impure)
  if [[ "$expected_user" != "$(id -un)" ]]; then
    echo "The $profile profile belongs to $expected_user. Configure your user under users/ or use the default essentials setup." >&2
    exit 1
  fi
  generation=$(nix_cmd build "$repo#homeConfigurations.$profile.activationPackage" \
    --impure --no-link --print-out-paths)
  HOME_MANAGER_BACKUP_EXT="before-dotfiles-$(date +%Y%m%d-%H%M%S)-$$" "$generation/activate"
  mkdir -p "$state"
  printf '%s\n' "$repo" > "$state/repository"
  printf '%s\n' "$profile" > "$state/home-profile"
fi

echo "3/3: Missing developer tools"
if (( ${#tools[@]} )); then
  if $dry; then
    run dev-setup "${tools[@]}"
  elif [[ ! -e /lib64/ld-linux-x86-64.so.2 && "$(uname -m)" == x86_64 ]]; then
    echo "Native tools need nix-ld. Rerun without --home-only to enable it." >&2
    exit 1
  else
    "$generation/home-path/bin/dev-setup" "${tools[@]}"
  fi
else
  echo "  Skipped. Install individually later with dev-setup."
fi
echo "Ready. Open a new terminal. hm/hmu manage your home; os/osu manage NixOS."
echo "Use hm --full when you want the complete Home Manager setup."
