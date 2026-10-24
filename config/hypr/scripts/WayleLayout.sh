#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Wayle Layout Selector
#  Part of the jakoolit-soberano fork project
# ==============================================================================

IFS=$'\n\t'

wayle_layouts="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/wayle/layouts"
wayle_config="${XDG_CONFIG_HOME:-$HOME/.config}/wayle/config.toml"
rofi_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-waybar-layout.rasi"
msg=' 🚀 SOBERANO: Escolha um Layout do Wayle (Convertido do JaKooLit)'

apply_layout() {
    selected_file="$wayle_layouts/$1.toml"
    if [ ! -f "$selected_file" ]; then
        echo "Arquivo $selected_file não encontrado."
        exit 1
    fi
    
    mkdir -p "$(dirname "$wayle_config")"
    cp -f "$selected_file" "$wayle_config"
    
    # Reload or restart Wayle gracefully via systemd or direct binary
    if systemctl --user is-active --quiet wayle.service; then
        systemctl --user restart wayle.service
    else
        pkill -x wayle || true
        wayle shell & disown
    fi
    
    notify-send -e -u low -i "preferences-desktop-theme" "Wayle Layout" "Layout '$1' aplicado com sucesso!"
}

main() {
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

    # Launch menu (Prioriza Fuzzel M3 nativo, fallback Rofi)
    if command -v fuzzel >/dev/null 2>&1; then
        choice=$(printf '%s\n' "${options[@]}" | fuzzel -d -p " 📐 Layout Wayle ❯ " -w 35 -l 15)
    elif command -v rofi >/dev/null 2>&1 && [ -f "$rofi_config" ]; then
        choice=$(printf '%s\n' "${options[@]}" \
            | rofi -i -dmenu \
                   -config "$rofi_config" \
                   -mesg "$msg"
        )
    else
        echo "Escolha um layout:"
        select choice in "${options[@]}"; do
            break
        done
    fi

    [[ -z "$choice" ]] && exit 0
    apply_layout "$choice"
}

main
