#!/usr/bin/env bash
# ==============================================================================
#  JaKooLit-Soberano: Universal Distro Installer & Launcher
#  Project: https://github.com/ViniciusPHDU20/jakoolit-soberano
# ==============================================================================

set -euo pipefail

# Visual helpers
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
RESET="$(tput sgr0)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
REPO_URL="https://github.com/ViniciusPHDU20/jakoolit-soberano.git"
TARGET_DIR="$HOME/jakoolit-soberano"

# 1. If running inside existing clone
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/install-soberano.sh" ]; then
    echo "${INFO} Executando instalador Soberano local...${RESET}"
    chmod +x "$SCRIPT_DIR/install-soberano.sh"
    exec "$SCRIPT_DIR/install-soberano.sh" "$@"
fi

# 2. Check Git dependency
if ! command -v git &> /dev/null; then
    echo "${INFO} Git não encontrado. Tentando instalar...${RESET}"
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y git
    fi
fi

# 3. Clone or pull repo
if [ -d "$TARGET_DIR" ]; then
    echo "${INFO} Repositório $TARGET_DIR já existe. Atualizando...${RESET}"
    cd "$TARGET_DIR"
    git stash || true
    git pull
else
    echo "${MAGENTA}Clonando JaKooLit-Soberano em $TARGET_DIR...${RESET}"
    git clone --depth=1 "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

chmod +x install-soberano.sh
exec ./install-soberano.sh "$@"
