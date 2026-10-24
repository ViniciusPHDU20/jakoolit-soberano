#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Wayle Visual Style Selector (Fuzzel M3 Edition)
#  Part of the jakoolit-soberano fork project
# ==============================================================================

IFS=$'\n\t'
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
wayle_styles_dir="$config_home/hypr/wayle/styles"
manager="$config_home/hypr/scripts/wayle_manager.py"

if [[ $# -gt 0 && -n "$1" ]]; then
    target_style="${1%.toml}"
    target_style="${target_style%.css}"
    python3 "$manager" apply-style "$target_style"
    exit $?
fi

if [[ ! -d "$wayle_styles_dir" ]]; then
    echo "Diretório de estilos não encontrado: $wayle_styles_dir"
    exit 1
fi

mapfile -t options < <(
    find -L "$wayle_styles_dir" -maxdepth 1 -type f -name '*.toml' \
        -exec basename {} .toml \; \
        | sort
)

if [[ ${#options[@]} -eq 0 ]]; then
    # Fallback to .css if tomls don't exist
    mapfile -t options < <(
        find -L "$wayle_styles_dir" -maxdepth 1 -type f -name '*.css' \
            -exec basename {} .css \; \
            | sort
    )
fi

if [[ ${#options[@]} -eq 0 ]]; then
    notify-send "Wayle Styles" "Nenhum estilo encontrado em $wayle_styles_dir"
    exit 1
fi

if pgrep -x "fuzzel" >/dev/null; then
    pkill -x "fuzzel" || true
fi

# Launch menu (Prioriza Fuzzel M3 nativo, fallback dmenu)
if command -v fuzzel >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | fuzzel -d -p "Style: " -w 35 -l 15)
elif command -v rofi >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | rofi -i -dmenu -p "Style")
else
    echo "Escolha um estilo:"
    select choice in "${options[@]}"; do
        break
    done
fi

[[ -z "$choice" ]] && exit 0

python3 "$manager" apply-style "$choice"
