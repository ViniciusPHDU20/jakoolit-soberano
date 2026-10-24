#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Wayle Layout Selector (Fuzzel M3 Edition)
#  Part of the jakoolit-soberano fork project
# ==============================================================================

IFS=$'\n\t'
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
wayle_layouts="$config_home/hypr/wayle/layouts"
manager="$config_home/hypr/scripts/wayle_manager.py"

if [[ $# -gt 0 && -n "$1" ]]; then
    target_layout="${1%.toml}"
    python3 "$manager" apply-layout "$target_layout"
    exit $?
fi

if [ ! -d "$wayle_layouts" ]; then
    echo "Diretório de layouts não encontrado: $wayle_layouts"
    exit 1
fi

mapfile -t options < <(
    find -L "$wayle_layouts" -maxdepth 1 -type f -name '*.toml' \
        -exec basename {} .toml \; \
        | sort
)

if [ ${#options[@]} -eq 0 ]; then
    echo "Nenhum layout encontrado."
    exit 1
fi

# Launch menu (Prioriza Fuzzel M3 nativo, fallback dmenu)
if command -v fuzzel >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | fuzzel -d -p "Layout: " -w 35 -l 15)
elif command -v rofi >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | rofi -i -dmenu -p "Layout")
else
    echo "Escolha um layout:"
    select choice in "${options[@]}"; do
        break
    done
fi

[[ -z "$choice" ]] && exit 0

python3 "$manager" apply-layout "$choice"
