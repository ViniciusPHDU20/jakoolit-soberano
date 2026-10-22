#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Unified Component & Bar Refresher
#  Part of the jakoolit-soberano fork project
# ==============================================================================

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
QS_TEXTINPUT_LOG_RULE="qt.qpa.wayland.textinput.warning=false"

# Kill already running menus
for p in rofi fuzzel ags; do
  if pidof "$p" >/dev/null 2>&1; then
    pkill "$p" 2>/dev/null || true
  fi
done

# Restart Wayle gracefully
restart_wayle() {
  if [ -x "$SCRIPTSDIR/WayleStartup.sh" ]; then
    "$SCRIPTSDIR/WayleStartup.sh" >/dev/null 2>&1 &
  elif systemctl --user is-active --quiet wayle.service 2>/dev/null; then
    systemctl --user restart wayle.service >/dev/null 2>&1 &
  else
    pkill -x wayle || true
    wayle shell >/dev/null 2>&1 &
  fi
}

# Restart dual-surface companion if running
restart_companion_bar() {
  if pgrep -x "soberano-cockpit-bar-rs" >/dev/null 2>&1 || systemctl --user is-active --quiet soberano-cockpit-bar.service 2>/dev/null; then
    if systemctl --user is-active --quiet soberano-cockpit-bar.service 2>/dev/null; then
      systemctl --user restart soberano-cockpit-bar.service >/dev/null 2>&1 &
    else
      pkill -x soberano-cockpit-bar-rs || true
      if command -v soberano-cockpit-bar-rs >/dev/null 2>&1; then
        soberano-cockpit-bar-rs >/dev/null 2>&1 &
      fi
    fi
  fi
}

restart_wayle
restart_companion_bar

# Reload SwayNC if present
if command -v swaync-client >/dev/null 2>&1; then
  (swaync-client -R -rs --skip-wait >/dev/null 2>&1 &)
fi

# Reload quickshell if running
if pgrep qs >/dev/null 2>&1; then
  pkill qs && qs --log-rules "$QS_TEXTINPUT_LOG_RULE" &
fi

# Re-apply Rainbow Borders if enabled
sleep 0.5
if [ -x "${SCRIPTSDIR}/RainbowBordersStartup.sh" ]; then
  "${SCRIPTSDIR}/RainbowBordersStartup.sh" >/dev/null 2>&1 || true
fi

exit 0
