#!/usr/bin/env bash
# ==============================================================================
#  Soberano Hyprland - Wallust Compatibility Wrapper -> Matugen
#  Part of the jakoolit-soberano fork project
# ==============================================================================

SCRIPTSDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -x "$SCRIPTSDIR/MatugenSwww.sh" ]; then
    exec "$SCRIPTSDIR/MatugenSwww.sh" "$@"
fi

exit 0
