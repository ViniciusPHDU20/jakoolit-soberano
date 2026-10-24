#!/usr/bin/env bash
# ==================================================
#  Soberano (2026) - Wayle Style Selector
#  Project: jakoolit-soberano
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
wayle_styles_dir="$config_home/hypr/wayle/styles"
wayle_active_style="$config_home/hypr/wayle/style.css"
scripts_dir="$config_home/hypr/scripts"
rofi_config="$config_home/hypr/rofi/config-waybar-style.rasi"

if [[ ! -d "$wayle_styles_dir" ]]; then
    mkdir -p "$wayle_styles_dir"
fi

current_target=$(readlink -f "$wayle_active_style" 2>/dev/null || echo "")
current_name=$(basename "$current_target" .css)

mapfile -t options < <(
    find -L "$wayle_styles_dir" -maxdepth 1 -type f -name '*.css' -printf '%f\n' \
        | sed 's/\.css$//' \
        | sort
)

if [[ "${#options[@]}" -eq 0 ]]; then
    notify-send "Wayle Styles" "No style presets found in $wayle_styles_dir"
    exit 1
fi

default_row=0
MARKER="👉"
for i in "${!options[@]}"; do
    if [[ "${options[i]}" == "$current_name" ]]; then
        options[i]="$MARKER ${options[i]}"
        default_row=$i
        break
    fi
done

if pgrep -x "fuzzel" >/dev/null; then
    pkill -x "fuzzel" || true
fi
if pgrep -x "rofi" >/dev/null; then
    pkill -x "rofi" || true
fi

if command -v fuzzel >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | fuzzel -d -p " 🎨 Estilo Wayle ❯ " -w 35 -l 15)
else
    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rofi_config" \
               -mesg " 🎨 Select Wayle Modern Visual Theme" \
               -selected-row "$default_row" 2>/dev/null || true)
fi

[[ -z "$choice" ]] && exit 0

choice="${choice#"$MARKER "}"
selected_file="$wayle_styles_dir/${choice}.css"

if [[ -f "$selected_file" ]]; then
    ln -sf "$selected_file" "$wayle_active_style"
    mkdir -p "$config_home/wayle"
    cp -f "$selected_file" "$config_home/wayle/style.css" 2>/dev/null || true
    
    if [[ -x "$scripts_dir/Refresh.sh" ]]; then
        "$scripts_dir/Refresh.sh" &
    fi
    notify-send -u low "Wayle Style Applied" "Active theme: $choice"
fi
