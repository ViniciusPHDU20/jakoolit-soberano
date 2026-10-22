#!/usr/bin/env bash
# ==============================================================================
#  JaKooLit-Soberano: Script de Instalação e Configuração (Bare Metal / VM)
#  Repositório: https://github.com/ViniciusPHDU20/jakoolit-soberano
# ==============================================================================

set -euo pipefail

# Cores para terminal
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}==============================================================================${RESET}"
echo -e "${GREEN}   🌌 JAKOOLIT-SOBERANO: Instalador Completo (Bare Metal & VM)              ${RESET}"
echo -e "${CYAN}==============================================================================${RESET}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Se o instalador for executado diretamente via curl/pipe (sem clone prévio)
if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR/config/hypr" ]; then
    echo -e "${YELLOW}⚡ Execução remota via curl/pipe detectada. Preparando ambiente...${RESET}"
    TARGET_DIR="$HOME/jakoolit-soberano"
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${BLUE}Instalando Git e sincronizando repositórios...${RESET}"
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --needed --noconfirm archlinux-keyring git || (sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman -Sy --needed --noconfirm archlinux-keyring git)
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        elif command -v zypper >/dev/null 2>&1; then
            sudo zypper install -y git
        fi
    fi
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${BLUE}Atualizando repositório existente em $TARGET_DIR...${RESET}"
        cd "$TARGET_DIR"
        git stash || true
        git pull || true
    else
        echo -e "${BLUE}Clonando repositório em $TARGET_DIR...${RESET}"
        git clone --depth=1 "https://github.com/ViniciusPHDU20/jakoolit-soberano.git" "$TARGET_DIR"
        cd "$TARGET_DIR"
    fi
    chmod +x install-soberano.sh
    exec ./install-soberano.sh "$@"
fi

# 1. Instalar dependências essenciais no Arch Linux / CachyOS / Manjaro
if command -v pacman >/dev/null 2>&1; then
    echo -e "\n${BLUE}[1/6] Verificando dependências no Arch Linux (Hardware Real & VM)...${RESET}"
    sudo pacman -Sy --noconfirm || true

    AUR_HELPER=""
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    else
        echo -e "${YELLOW}AUR helper não encontrado. Instalando 'yay' automaticamente...${RESET}"
        sudo pacman -S --needed --noconfirm base-devel git || true
        YAY_TMP="$(mktemp -d)"
        if git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$YAY_TMP"; then
            (cd "$YAY_TMP" && makepkg -si --noconfirm) || true
        fi
        rm -rf "$YAY_TMP"
        if command -v yay >/dev/null 2>&1; then
            AUR_HELPER="yay"
            echo -e "${GREEN}✓ yay instalado com sucesso.${RESET}"
        fi
    fi

    # Pacotes da stack Soberano + ferramentas de hardware real (Áudio, Bluetooth, Brilho, Portals)
    PACKAGES=(
        hyprland
        matugen-bin
        wayle-shell
        kitty
        fuzzel
        rofi-wayland
        swww
        wl-clipboard
        brightnessctl
        playerctl
        pamixer
        pavucontrol
        swaync
        network-manager-applet
        bluez
        bluez-utils
        blueman
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        grim
        slurp
        cliphist
    )
    MISSING_PKGS=()

    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1 && ! command -v "${pkg%%-*}" >/dev/null 2>&1; then
            MISSING_PKGS+=("$pkg")
        fi
    done

    if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
        if [ -n "$AUR_HELPER" ]; then
            echo -e "${YELLOW}Instalando pacotes necessários: ${MISSING_PKGS[*]}${RESET}"
            $AUR_HELPER -S --needed --noconfirm "${MISSING_PKGS[@]}" || true
        else
            echo -e "${YELLOW}Aviso: Instale via seu gerenciador: ${MISSING_PKGS[*]}${RESET}"
        fi
    else
        echo -e "${GREEN}✓ Todos os pacotes essenciais do sistema estão instalados.${RESET}"
    fi
fi

# 2. Copiar as configurações para ~/.config
echo -e "\n${BLUE}[2/6] Copiando configurações para $CONFIG_DIR...${RESET}"
mkdir -p "$CONFIG_DIR"

# Cria backups de segurança se já existirem configurações
for d in hypr wayle matugen kitty fuzzel; do
    if [ -d "$CONFIG_DIR/$d" ]; then
        echo -e "${YELLOW}Criando backup de ~/.config/$d...${RESET}"
        mv "$CONFIG_DIR/$d" "$CONFIG_DIR/${d}_backup_$(date +%s)" || true
    fi
done

# Copia configurações da nova stack
cp -r "$DOTFILES_DIR/config/hypr" "$CONFIG_DIR/"
cp -r "$DOTFILES_DIR/config/matugen" "$CONFIG_DIR/"
mkdir -p "$CONFIG_DIR/wayle"

# 3. Detecção e Ajuste Automático de Hardware (GPU / Laptop / VM)
echo -e "\n${BLUE}[3/6] Detectando hardware e aplicando otimizações...${RESET}"
PCI_INFO="$(lspci -k 2>/dev/null | grep -A 2 -E "(VGA|3D)" || true)"

IS_NVIDIA=0
if echo "$PCI_INFO" | grep -iq nvidia; then
    IS_NVIDIA=1
fi

IS_VM=0
if hostnamectl 2>/dev/null | grep -q 'Chassis: vm' || (command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt -q); then
    IS_VM=1
fi

IS_LAPTOP=0
if [ -d /sys/class/power_supply ] && ls /sys/class/power_supply/ | grep -qE '^BAT[0-9]+'; then
    IS_LAPTOP=1
fi

ENV_LUA="$CONFIG_DIR/hypr/lua/env.lua"
SETTINGS_LUA="$CONFIG_DIR/hypr/lua/settings.lua"

if [ "$IS_NVIDIA" -eq 1 ]; then
    echo -e "${MAGENTA}⚡ GPU NVIDIA detectada! Configurando drivers proprietários e cursor de software...${RESET}"
    if [ -f "$ENV_LUA" ]; then
        sed -i 's/^--[[:space:]]*hl\.env("LIBVA_DRIVER_NAME"/hl.env("LIBVA_DRIVER_NAME"/' "$ENV_LUA"
        sed -i 's/^--[[:space:]]*hl\.env("__GLX_VENDOR_LIBRARY_NAME"/hl.env("__GLX_VENDOR_LIBRARY_NAME"/' "$ENV_LUA"
        sed -i 's/^--[[:space:]]*hl\.env("NVD_BACKEND"/hl.env("NVD_BACKEND"/' "$ENV_LUA"
        sed -i 's/^--[[:space:]]*hl\.env("GSK_RENDERER"/hl.env("GSK_RENDERER"/' "$ENV_LUA"
    fi
    if [ -f "$SETTINGS_LUA" ]; then
        sed -i -E 's/^([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*)[0-9]+/\1 1/' "$SETTINGS_LUA"
    fi
elif [ "$IS_VM" -eq 1 ]; then
    echo -e "${YELLOW}🖥️  Ambiente Virtual (VM) detectado. Ativando renderização de software e compatibilidade...${RESET}"
    if [ -f "$ENV_LUA" ]; then
        sed -i 's/^--[[:space:]]*hl\.env("WLR_RENDERER_ALLOW_SOFTWARE"/hl.env("WLR_RENDERER_ALLOW_SOFTWARE"/' "$ENV_LUA"
    fi
    if [ -f "$SETTINGS_LUA" ]; then
        sed -i -E 's/^([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*)[0-9]+/\1 1/' "$SETTINGS_LUA"
    fi
else
    echo -e "${GREEN}✓ GPU AMD/Intel nativa detectada. Drivers Mesa Direct Rendering ativos (zero overhead).${RESET}"
fi

if [ "$IS_LAPTOP" -eq 1 ]; then
    echo -e "${GREEN}✓ Laptop detectado: Módulo de bateria e atalhos de brilho prontos.${RESET}"
fi

# 4. Configurar Layout Inicial do Wayle (TOP-Default)
echo -e "\n${BLUE}[4/6] Configurando layout inicial do Wayle...${RESET}"
DEFAULT_LAYOUT="$CONFIG_DIR/hypr/wayle/layouts/TOP-Default.toml"
if [ -f "$DEFAULT_LAYOUT" ]; then
    cp -f "$DEFAULT_LAYOUT" "$CONFIG_DIR/wayle/config.toml"
    echo -e "${GREEN}✓ Layout 'TOP-Default' ativado como padrão do Wayle.${RESET}"
fi

# 5. Configurar Papéis de Parede e gerar paleta inicial com Matugen
echo -e "\n${BLUE}[5/6] Gerando paleta de cores inicial (Matugen Material You)...${RESET}"
mkdir -p "$HOME/Pictures/wallpapers"
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -r "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/" || true
fi

DEFAULT_WALL=$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1 || true)
if [ -n "$DEFAULT_WALL" ] && command -v matugen >/dev/null 2>&1; then
    echo -e "🎨 Extraindo cores de $DEFAULT_WALL..."
    matugen image "$DEFAULT_WALL" || true
fi

# 6. Permissões de execução dos scripts
echo -e "\n${BLUE}[6/6] Ajustando permissões de execução dos scripts...${RESET}"
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh || true
chmod +x "$CONFIG_DIR/hypr/UserScripts/"*.sh || true

echo -e "\n${GREEN}==============================================================================${RESET}"
echo -e "${GREEN}   🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!                                     ${RESET}"
echo -e "${GREEN}==============================================================================${RESET}"
echo -e "${CYAN}Instruções de uso (Bare Metal ou VM):${RESET}"
echo -e " 1. Inicie sua sessão Wayland: ${YELLOW}Hyprland${RESET}"
echo -e " 2. A barra ${GREEN}Wayle${RESET} iniciará automaticamente com suporte total a Material You."
echo -e " 3. Pressione ${YELLOW}SUPER + ALT + B${RESET} para trocar entre os ${GREEN}47 layouts${RESET} do JaKooLit."
echo -e " 4. Pressione ${YELLOW}SUPER + W${RESET} para trocar de wallpaper (recalculando a paleta dinamicamente)."
echo -e " 5. Se estiver em Laptop, teclas de brilho e bateria estão 100% integradas."
echo -e "\nPronto para uso diário em máquina real ou VM!\n"
