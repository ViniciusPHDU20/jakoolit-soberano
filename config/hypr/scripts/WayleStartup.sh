#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Dedicated Startup Helper for Wayle
#  Part of the jakoolit-soberano fork project
# ==============================================================================

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_RUNTIME_DIR="$runtime_dir"
SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
WAYLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/wayle/config.toml"
DEFAULT_LAYOUT="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/wayle/layouts/TOP-Default.toml"

wait_for_wayland() {
    if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -S "$runtime_dir/$WAYLAND_DISPLAY" ]; then
        return 0
    fi
    for _ in $(seq 1 30); do
        for socket in "$runtime_dir"/wayland-[0-9]*; do
            [ -S "$socket" ] || continue
            case "$(basename "$socket")" in
                *awww*) continue ;;
            esac
            export WAYLAND_DISPLAY="$(basename "$socket")"
            return 0
        done
        sleep 0.1
    done
    return 1
}

main() {
    wait_for_wayland || true

    # Ensure wayle config exists
    if [ ! -f "$WAYLE_CONFIG" ]; then
        mkdir -p "$(dirname "$WAYLE_CONFIG")"
        if [ -f "$DEFAULT_LAYOUT" ]; then
            cp "$DEFAULT_LAYOUT" "$WAYLE_CONFIG"
        fi
    fi

    # Check if wayle is managed by systemd
    if systemctl --user is-enabled wayle.service >/dev/null 2>&1; then
        systemctl --user restart wayle.service || systemctl --user start wayle.service
    else
        pkill -x wayle || true
        wayle shell & disown
    fi
}

main "$@"
