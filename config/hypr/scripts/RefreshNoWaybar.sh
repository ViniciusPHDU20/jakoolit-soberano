#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Lightweight Background Refresher
#  Part of the jakoolit-soberano fork project
# ==============================================================================

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"

# Reload SwayNC if present
if command -v swaync-client >/dev/null 2>&1; then
  (swaync-client -R -rs --skip-wait >/dev/null 2>&1 &)
fi

# Re-apply Rainbow Borders if enabled
sleep 0.5
if [ -x "${SCRIPTSDIR}/RainbowBordersStartup.sh" ]; then
  "${SCRIPTSDIR}/RainbowBordersStartup.sh" >/dev/null 2>&1 || true
fi

exit 0
