#!/usr/bin/env python3
"""
Waybar-to-Wayle Transpiler
Converts JaKooLit Waybar JSONC configs into native Wayle TOML layout presets.
Part of the jakoolit-soberano fork project.
"""

import os
import re
import json
from pathlib import Path

# Module mappings from Waybar syntax to Wayle native modules
MODULE_MAP = {
    # Workspaces and Windows
    "hyprland/workspaces": "hyprland-workspaces",
    "wlr/workspaces": "hyprland-workspaces",
    "hyprland/window": "window-title",
    "wlr/taskbar": "window-title",
    "hyprland/submap": "hyprland-submap",
    
    # Audio and Media
    "pulseaudio": "volume",
    "pulseaudio#microphone": "microphone",
    "custom/playerctl": "media",
    "mpris": "media",
    "cava": "cava",
    "custom/cava_mviz": "cava",
    
    # System Status & Hardware
    "clock": "clock",
    "battery": "battery",
    "cpu": "cpu",
    "memory": "memory",
    "disk": "disk",
    "temperature": "temperature",
    "network": "network",
    "bluetooth": "bluetooth",
    "tray": "systray",
    
    # UI & Power
    "custom/pmenu": "dashboard",
    "custom/power": "power",
    "custom/lock": "power",
    "custom/cycle_wall": "wallpaper",
    "custom/updater": "updates",
    "custom/updates": "updates",
    "custom/notifications": "notifications",
    "group/notify": "notifications",
}

def strip_jsonc_comments(text: str) -> str:
    """Strip single-line (//) and multi-line (/* */) comments from JSONC."""
    # Remove multi-line comments
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    # Remove single-line comments (ignoring urls like https://)
    lines = []
    for line in text.splitlines():
        # Match // not preceded by :
        line = re.sub(r'(?<!:)\s*//.*$', '', line)
        lines.append(line)
    return "\n".join(lines)

def map_modules(module_list):
    """Filter and map waybar modules into clean Wayle modules."""
    res = []
    for m in module_list:
        if isinstance(m, str):
            # Skip blank separators or dividers in wayle (spacing handles them)
            if "separator" in m or m in ("custom/l_g_div", "custom/r_g_div"):
                continue
            # Strip custom suffixes (e.g. "pulseaudio#1" -> "pulseaudio")
            base = m.split('#')[0]
            mapped = MODULE_MAP.get(m, MODULE_MAP.get(base, None))
            if mapped and mapped not in res:
                res.append(mapped)
    return res

def parse_waybar_config(content: str):
    """Parse JSON or JSONC content safely."""
    cleaned = strip_jsonc_comments(content)
    # Remove trailing commas before } or ]
    cleaned = re.sub(r',\s*([}\]])', r'\1', cleaned)
    try:
        return json.loads(cleaned)
    except Exception as e:
        # Fallback regex extraction if JSON parser chokes on complex includes
        left = re.findall(r'"modules-left"\s*:\s*\[(.*?)\]', cleaned, re.DOTALL)
        center = re.findall(r'"modules-center"\s*:\s*\[(.*?)\]', cleaned, re.DOTALL)
        right = re.findall(r'"modules-right"\s*:\s*\[(.*?)\]', cleaned, re.DOTALL)
        pos = re.search(r'"position"\s*:\s*"(\w+)"', cleaned)
        
        def extract_items(blob):
            if not blob: return []
            return [x.strip(' ",\'\t') for x in blob[0].split(',') if x.strip(' ",\'\t')]

        return {
            "position": pos.group(1) if pos else "top",
            "modules-left": extract_items(left),
            "modules-center": extract_items(center),
            "modules-right": extract_items(right),
        }

def toml_format_modules(modules):
    """Format module list into TOML array."""
    if not modules:
        return "[]"
    items = ', '.join(f'"{m}"' for m in modules)
    return f"[{items}]"

def transpile_file(waybar_path: Path, output_dir: Path):
    """Transpile a single Waybar config into a Wayle TOML preset."""
    try:
        raw = waybar_path.read_text(encoding='utf-8', errors='ignore')
        data = parse_waybar_config(raw)
        
        # Handle multi-bar JSON arrays (e.g. [ {topbar}, {bottombar} ])
        dual_surface = False
        bottom_bar_data = None
        if isinstance(data, list):
            if len(data) > 1:
                dual_surface = True
                bottom_bar_data = data[1]
            data = data[0] if len(data) > 0 else {}
            
        pos = data.get("position", "top").lower()
        if pos not in ("top", "bottom", "left", "right"):
            pos = "top"
            
        left_m = map_modules(data.get("modules-left", []))
        center_m = map_modules(data.get("modules-center", []))
        right_m = map_modules(data.get("modules-right", []))
        
        # Ensure essential defaults if waybar used empty groupings
        if not left_m and not center_m and not right_m:
            left_m = ["dashboard", "hyprland-workspaces"]
            center_m = ["clock"]
            right_m = ["volume", "network", "systray"]

        clean_name = waybar_path.name.replace("[", "").replace("]", "").replace(" ", "-").replace("&", "and")
        out_file = output_dir / f"{clean_name}.toml"
        
        companion_note = ""
        if dual_surface and bottom_bar_data:
            bot_left = map_modules(bottom_bar_data.get("modules-left", []))
            bot_center = map_modules(bottom_bar_data.get("modules-center", []))
            bot_right = map_modules(bottom_bar_data.get("modules-right", []))
            companion_note = f"""
# [Dual-Surface Companion]
# This was a multi-bar preset in JaKooLit. The companion bottom bar layout:
# bottom_left = {toml_format_modules(bot_left)}
# bottom_center = {toml_format_modules(bot_center)}
# bottom_right = {toml_format_modules(bot_right)}
"""

        toml_content = f"""# ==============================================================================
# Wayle Layout Preset: {waybar_path.name}
# Automatically converted from JaKooLit Waybar config
# Project: jakoolit-soberano (Next-Gen Wayle + Matugen)
# =============================================================================={companion_note}

[bar]
location = "{pos}"
scale = 1.0
exclusive = true
bg = "bg-surface"
background-opacity = 96
rounding = "sm"
border-location = "all"
border-width = 1
border-color = "border-accent"
module-gap = 0.4
padding = 0.2
padding-ends = 0.4

[styling]
scale = 1.0
rounding = "sm"
theme-provider = "matugen"

[[bar.layout]]
monitor = "*"
show = true
left = [
    {{ name = "left-group", modules = {toml_format_modules(left_m)} }}
]
center = [
    {{ name = "center-group", modules = {toml_format_modules(center_m)} }}
]
right = [
    {{ name = "right-group", modules = {toml_format_modules(right_m)} }}
]
"""
        out_file.write_text(toml_content, encoding='utf-8')
        return True, out_file.name
    except Exception as e:
        return False, f"{waybar_path.name}: {e}"

def main():
    base_dir = Path(__file__).resolve().parent.parent
    waybar_configs_dir = base_dir / "config" / "hypr" / "waybar" / "configs"
    wayle_layouts_dir = base_dir / "config" / "hypr" / "wayle" / "layouts"
    
    wayle_layouts_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Transpiling Waybar configs from {waybar_configs_dir} to {wayle_layouts_dir}...")
    success_count = 0
    fail_count = 0
    
    for f in sorted(waybar_configs_dir.iterdir()):
        if f.is_file():
            ok, name = transpile_file(f, wayle_layouts_dir)
            if ok:
                success_count += 1
                print(f"  [OK] {f.name} -> {name}")
            else:
                fail_count += 1
                print(f"  [ERROR] {name}")
                
    print(f"\nCompleted: {success_count} converted successfully, {fail_count} failed.")

if __name__ == "__main__":
    main()
