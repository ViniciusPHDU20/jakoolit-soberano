#!/usr/bin/env python3
"""
Soberano Wayle State & Theme Manager
Seamlessly handles dynamic switching of 47 Layouts and 53 Styles in Wayle GTK4
Part of jakoolit-soberano fork
"""
import sys
import os
import shutil
import subprocess

CONFIG_DIR = os.path.expanduser("~/.config")
WAYLE_CONFIG_PATH = os.path.join(CONFIG_DIR, "wayle", "config.toml")
WAYLE_DIR = os.path.join(CONFIG_DIR, "hypr", "wayle")
LAYOUTS_DIR = os.path.join(WAYLE_DIR, "layouts")
STYLES_DIR = os.path.join(WAYLE_DIR, "styles")

DEFAULT_STYLING = """
[styling]
scale = 1.0
rounding = "sm"
theme-provider = "wayle"

[styling.palette]
bg = "#1e1e2e"
surface = "#181825"
elevated = "#313244"
fg = "#cdd6f4"
fg-muted = "#a6adc8"
primary = "#cba6f7"
red = "#f38ba8"
yellow = "#f9e2af"
green = "#a6e3a1"
blue = "#89b4fa"
"""

def notify(title, message, icon="preferences-desktop-theme"):
    try:
        subprocess.run(["notify-send", "-e", "-u", "low", "-i", icon, title, message], check=False)
    except Exception:
        pass

def restart_wayle():
    try:
        subprocess.run(["pkill", "-x", "wayle"], check=False)
        # Ensure wayle shell is spawned in background
        subprocess.Popen(["wayle", "shell"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    except Exception as e:
        print(f"Error restarting wayle: {e}", file=sys.stderr)

def get_current_sections():
    if not os.path.isfile(WAYLE_CONFIG_PATH):
        return None, None
    try:
        with open(WAYLE_CONFIG_PATH, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Split into bar vs styling
        bar_part = ""
        styling_part = ""
        
        if "[styling]" in content:
            idx = content.index("[styling]")
            bar_part = content[:idx].strip()
            styling_part = content[idx:].strip()
        else:
            bar_part = content.strip()
            styling_part = DEFAULT_STYLING.strip()
            
        return bar_part, styling_part
    except Exception:
        return None, None

def apply_layout(layout_name):
    clean_name = layout_name.replace(".toml", "")
    layout_file = os.path.join(LAYOUTS_DIR, f"{clean_name}.toml")
    
    if not os.path.isfile(layout_file):
        print(f"Layout '{clean_name}' not found at {layout_file}", file=sys.stderr)
        return False
        
    with open(layout_file, "r", encoding="utf-8") as f:
        layout_content = f.read().strip()
        
    _, current_styling = get_current_sections()
    if not current_styling:
        current_styling = DEFAULT_STYLING.strip()
        
    os.makedirs(os.path.dirname(WAYLE_CONFIG_PATH), exist_ok=True)
    full_config = f"{layout_content}\n\n{current_styling}\n"
    
    with open(WAYLE_CONFIG_PATH, "w", encoding="utf-8") as f:
        f.write(full_config)
        
    restart_wayle()
    notify("Wayle Layout", f"Layout '{clean_name}' aplicado com sucesso!")
    print(f"Successfully applied layout: {clean_name}")
    return True

def apply_style(style_name):
    clean_name = style_name.replace(".toml", "").replace(".css", "")
    style_file = os.path.join(STYLES_DIR, f"{clean_name}.toml")
    
    if not os.path.isfile(style_file):
        print(f"Style '{clean_name}' not found at {style_file}", file=sys.stderr)
        return False
        
    with open(style_file, "r", encoding="utf-8") as f:
        style_content = f.read()
        
    current_bar, _ = get_current_sections()
    if not current_bar:
        # Fallback to TOP-Default layout if no bar section exists
        default_layout_file = os.path.join(LAYOUTS_DIR, "TOP-Default.toml")
        if os.path.isfile(default_layout_file):
            with open(default_layout_file, "r", encoding="utf-8") as lf:
                current_bar = lf.read().strip()
        else:
            current_bar = """[bar]
location = "top"
inset-edge = 8.0
inset-ends = 24.0
rounding = "full"
shadow = "floating"
background-opacity = 85

[[bar.layout]]
monitor = "*"
left = ["hyprland-workspaces"]
center = ["clock"]
right = ["volume", "power"]"""

    # Parse [bar_style] overrides if present in style file
    styling_part = style_content
    if "[bar_style]" in style_content:
        parts = style_content.split("[bar_style]")
        styling_part = parts[0].strip()
        bar_overrides = parts[1].strip()
        
        # Apply button-variant and opacity overrides into current_bar
        for line in bar_overrides.splitlines():
            line = line.strip()
            if not line or "=" not in line:
                continue
            key, val = [x.strip() for x in line.split("=", 1)]
            # If key already in bar, replace it, else append to [bar]
            if f"{key} =" in current_bar:
                current_bar = "\n".join(
                    f"{key} = {val}" if l.strip().startswith(f"{key} =") else l
                    for l in current_bar.splitlines()
                )

    os.makedirs(os.path.dirname(WAYLE_CONFIG_PATH), exist_ok=True)
    full_config = f"{current_bar}\n\n{styling_part}\n"
    
    with open(WAYLE_CONFIG_PATH, "w", encoding="utf-8") as f:
        f.write(full_config)
        
    restart_wayle()
    notify("Wayle Estilo", f"Tema visual '{clean_name}' aplicado!")
    print(f"Successfully applied style: {clean_name}")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: wayle_manager.py [apply-layout|apply-style] <name>")
        sys.exit(1)
        
    action = sys.argv[1]
    name = sys.argv[2]
    
    if action == "apply-layout":
        if not apply_layout(name):
            sys.exit(1)
    elif action == "apply-style":
        if not apply_style(name):
            sys.exit(1)
    else:
        print(f"Unknown action: {action}", file=sys.stderr)
        sys.exit(1)
