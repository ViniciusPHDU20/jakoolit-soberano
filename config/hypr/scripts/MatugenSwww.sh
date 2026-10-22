#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Matugen Dynamic Color Generator
#  Part of the jakoolit-soberano fork project
# ==============================================================================

set -euo pipefail

WALLPAPER="${1:-}"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Uso: $0 /caminho/para/wallpaper.jpg"
    exit 1
fi

echo "🎨 SOBERANO: Extraindo paleta de cores via Matugen..."
matugen image "$WALLPAPER"

# Notifica usuário
if command -v notify-send >/dev/null 2>&1; then
    notify-send -e -u low -i "$WALLPAPER" "Soberano Theming" "Paleta Material You (Matugen) aplicada com sucesso!"
fi
