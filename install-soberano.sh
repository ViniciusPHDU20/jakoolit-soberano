#!/usr/bin/env bash
# ==============================================================================
#  JaKooLit-Soberano: Script de Instalação e Teste (VM / Bare Metal)
#  Repositório: https://github.com/ViniciusPHDU20/jakoolit-soberano
# ==============================================================================

set -euo pipefail

# Cores para terminal
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}==============================================================================${RESET}"
echo -e "${GREEN}   🌌 JAKOOLIT-SOBERANO: Instalador Next-Gen (Wayle + Matugen)               ${RESET}"
echo -e "${CYAN}==============================================================================${RESET}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# 1. Instalar dependências essenciais caso esteja em Arch Linux / CachyOS / Manjaro
if command -v pacman >/dev/null 2>&1; then
    echo -e "\n${BLUE}[1/5] Verificando dependências no Arch Linux...${RESET}"
    AUR_HELPER=""
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    fi

    PACKAGES=(hyprland matugen-bin wayle-shell kitty fuzzel rofi-wayland swww wl-clipboard)
    MISSING_PKGS=()

    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1 && ! command -v "${pkg%%-*}" >/dev/null 2>&1; then
            MISSING_PKGS+=("$pkg")
        fi
    done

    if [ ${#MISSING_PKGS[@]} -gt 0 ] && [ -n "$AUR_HELPER" ]; then
        echo -e "${YELLOW}Instalando pacotes necessários: ${MISSING_PKGS[*]}${RESET}"
        $AUR_HELPER -S --needed --noconfirm "${MISSING_PKGS[@]}" || true
    fi
fi

# 2. Copiar as configurações para ~/.config
echo -e "\n${BLUE}[2/5] Copiando configurações para $CONFIG_DIR...${RESET}"
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

# 3. Configurar Layout Inicial do Wayle (TOP-Default)
echo -e "\n${BLUE}[3/5] Configurando layout inicial do Wayle...${RESET}"
DEFAULT_LAYOUT="$CONFIG_DIR/hypr/wayle/layouts/TOP-Default.toml"
if [ -f "$DEFAULT_LAYOUT" ]; then
    cp -f "$DEFAULT_LAYOUT" "$CONFIG_DIR/wayle/config.toml"
    echo -e "${GREEN}✓ Layout 'TOP-Default' ativado como padrão do Wayle.${RESET}"
fi

# 4. Configurar Papéis de Parede e gerar paleta inicial com Matugen
echo -e "\n${BLUE}[4/5] Gerando paleta de cores inicial (Matugen Material You)...${RESET}"
mkdir -p "$HOME/Pictures/wallpapers"
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -r "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/" || true
fi

DEFAULT_WALL=$(find "$HOME/Pictures/wallpapers" -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1 || true)
if [ -n "$DEFAULT_WALL" ] && command -v matugen >/dev/null 2>&1; then
    echo -e "🎨 Extraindo cores de $DEFAULT_WALL..."
    matugen image "$DEFAULT_WALL" || true
fi

# 5. Permissões de execução dos scripts
echo -e "\n${BLUE}[5/5] Ajustando permissões de execução dos scripts...${RESET}"
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh || true
chmod +x "$CONFIG_DIR/hypr/UserScripts/"*.sh || true

echo -e "\n${GREEN}==============================================================================${RESET}"
echo -e "${GREEN}   🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!                                     ${RESET}"
echo -e "${GREEN}==============================================================================${RESET}"
echo -e "${CYAN}Como testar na sua VM:${RESET}"
echo -e " 1. Inicie a sessão: ${YELLOW}Hyprland${RESET}"
echo -e " 2. A barra ${GREEN}Wayle${RESET} iniciará automaticamente com o layout clássico do JaKooLit."
echo -e " 3. Pressione ${YELLOW}SUPER + ALT + B${RESET} para abrir o seletor com todos os ${GREEN}47 layouts${RESET} convertidos."
echo -e " 4. Pressione ${YELLOW}SUPER + W${RESET} para escolher qualquer wallpaper (o Matugen recalculará as cores em tempo real)."
echo -e "\nAproveite os rices do JaKooLit rodando na nova geração Wayle & Matugen!\n"
