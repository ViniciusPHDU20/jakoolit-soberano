#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Matugen Dynamic Color Generator & Dispatcher
#  Part of the jakoolit-soberano fork project
# ==============================================================================

set -euo pipefail

ensure_wayland_env() {
  local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  if [ -z "${WAYLAND_DISPLAY:-}" ] || [ ! -S "$runtime_dir/$WAYLAND_DISPLAY" ]; then
    for socket in "$runtime_dir"/wayland-[0-9]*; do
      [ -S "$socket" ] || continue
      case "$(basename "$socket")" in
        *awww*) continue ;;
      esac
      export WAYLAND_DISPLAY="$(basename "$socket")"
      break
    done
  fi

  if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    for sig_dir in "$runtime_dir"/hypr/*/; do
      [ -S "${sig_dir}.socket.sock" ] || continue
      export HYPRLAND_INSTANCE_SIGNATURE="$(basename "$sig_dir")"
      break
    done
  fi
}

passed_path="${1:-}"
rofi_link="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/.current_wallpaper"
wallpaper_current="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/wallpaper_effects/.wallpaper_current"

wallpaper_path=""
if [[ -n "$passed_path" && -f "$passed_path" ]]; then
  wallpaper_path="$passed_path"
elif [[ -f "$wallpaper_current" ]]; then
  wallpaper_path="$wallpaper_current"
elif [[ -L "$rofi_link" ]]; then
  wallpaper_path="$(readlink -f "$rofi_link" 2>/dev/null || true)"
fi

if [[ -z "${wallpaper_path:-}" || ! -f "$wallpaper_path" ]]; then
  # Fallback: find any wallpaper in Pictures/wallpapers
  wallpaper_path="$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "${wallpaper_path:-}" || ! -f "$wallpaper_path" ]]; then
  exit 0
fi

# Update links for Rofi / Wallpaper effects
mkdir -p "$(dirname "$rofi_link")" "$(dirname "$wallpaper_current")"
ln -sf "$wallpaper_path" "$rofi_link" || true
cp -f "$wallpaper_path" "$wallpaper_current" || true

# Run Matugen to regenerate all templates (GTK, Hyprland, Rofi, Kitty, Fuzzel, Btop)
if command -v matugen >/dev/null 2>&1; then
  matugen_config="${XDG_CONFIG_HOME:-$HOME/.config}/matugen/config.toml"
  if [ -f "$matugen_config" ]; then
    matugen -c "$matugen_config" image "$wallpaper_path" >/dev/null 2>&1 || true
  else
    matugen image "$wallpaper_path" >/dev/null 2>&1 || true
  fi
fi

# Reload terminal colors (Kitty)
if pidof kitty >/dev/null 2>&1; then
  for pid in $(pidof kitty); do
    kill -SIGUSR1 "$pid" 2>/dev/null || true
  done
fi

# Reload terminal colors (Ghostty)
if pidof ghostty >/dev/null 2>&1; then
  for pid in $(pidof ghostty); do
    kill -SIGUSR2 "$pid" 2>/dev/null || true
  done
fi

# Reload Hyprland borders
if command -v hyprctl >/dev/null 2>&1; then
  ensure_wayland_env
  hyprctl reload config-only >/dev/null 2>&1 || true
fi

# Re-apply Rainbow Borders mode if enabled
rainbow_startup="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/RainbowBordersStartup.sh"
if [ -x "$rainbow_startup" ]; then
  "$rainbow_startup" >/dev/null 2>&1 || true
fi

exit 0
