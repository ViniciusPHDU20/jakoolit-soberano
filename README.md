# 🌌 JaKooLit-Soberano (Next-Gen Wayle & Matugen Edition)

> **Fork moderno, reengenheirado e otimizado dos renomados dotfiles de [JaKooLit / LinuxBeginnings](https://github.com/LinuxBeginnings/Hyprland-Dots).**  
> **Transição integral da stack legada (Waybar GTK3 + dezenas de scripts bash concorrentes + Wallust) para a moderna arquitetura em Rust & GTK4 (Wayle + Matugen Material You M3 + Dual-Surface Companion).**

---

## ⚡ Destaques da Nova Arquitetura Soberana

- 🚀 **Wayle Shell em Rust / GTK4**: Substituição nativa do Waybar pelo Wayle. Elimina centenas de chamadas `fork()`/`execve()` a cada poucos segundos, reduz o uso de memória pela metade e oferece taxa de quadros a 144Hz/165Hz com hot-reload assíncrono via D-Bus e sockets UNIX do Hyprland.
- 🎨 **Matugen 100% (Material Design 3)**: Cores e contrastes harmônicos extraídos diretamente de qualquer papel de parede em tempo real via algoritmo oficial M3 da Google, sincronizando simultaneamente Hyprland, Kitty, Ghostty, Fuzzel, Rofi, Btop e GTK 3/4.
- 📐 **47 Presets Convertidos**: Todos os 47 layouts icônicos criados pelo JaKooLit (`SummitSplit`, `Camellia`, `Peony`, `TOP-Default`, `[TOP & BOT] SummitSplit v3`, etc.) foram transpilados e validados para TOML nativo do Wayle em `config/hypr/wayle/layouts/`.
- 🛡️ **Dual-Surface Rust Companion**: Módulo em Rust puro (`tools/soberano-cockpit-bar-rs`) compilado nativamente para orquestrar barras duplas simultâneas (cockpit inferior com volume, rede e painel de notificações).
- 🔄 **Transpilador Incluso**: Ferramenta automatizada `tools/waybar_to_wayle_transpiler.py` para converter quaisquer novas configurações do ecossistema Waybar para Wayle TOML.
- 🍱 **Compatibilidade Total com Rofi e Temas**: Todos os 23 layouts visuais do Rofi herdam dinamicamente as cores do Matugen através de templates dedicados, sem quebrar os seletores clássicos.

---

## 📸 Visão Geral dos Rices

| Layout Clássico | Matugen Dynamic Theming | Dual-Surface Cockpit |
|:---:|:---:|:---:|
| **TOP-Default / Summit** | **Material You M3 Palette** | **Wayle + Rust Companion** |
| Alta performance, zero polling | Adaptação automática ao wallpaper | Cockpit multissuperfície |

---

## 🚀 Instalação Rápida (VM ou Bare Metal)

### Método 1: Instalador Automatizado Soberano (Recomendado)

O instalador detecta a distribuição (Arch Linux, CachyOS, Manjaro, etc.), instala automaticamente os pacotes modernos (`wayle-shell`, `matugen-bin`, `hyprland`, `kitty`, `fuzzel`, `swww`) e implanta as configurações:

```bash
git clone --depth=1 https://github.com/ViniciusPHDU20/jakoolit-soberano.git
cd jakoolit-soberano
chmod +x install-soberano.sh
./install-soberano.sh
```

### Método 2: Instalação Manual ou Upgrade de Dotfiles Existentes

Se você já possui as ferramentas instaladas e deseja apenas aplicar as configurações preservando seus backups:

```bash
git clone --depth=1 https://github.com/ViniciusPHDU20/jakoolit-soberano.git
cd jakoolit-soberano
chmod +x copy.sh
./copy.sh
```

---

## ⌨️ Principais Atalhos de Teclado (Keybinds)

| Atalho | Ação | Descrição |
|:---|:---|:---|
| <kbd>SUPER</kbd> + <kbd>ALT</kbd> + <kbd>B</kbd> | **Seletor de Layouts Wayle** | Menu Rofi/Fuzzel com os 47 layouts transpilados |
| <kbd>SUPER</kbd> + <kbd>CTRL</kbd> + <kbd>B</kbd> | **Seletor de Estilos Wayle** | Alterna estilos (Matugen-Dynamic, Catppuccin, Cyber-Chroma, etc.) |
| <kbd>SUPER</kbd> + <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>B</kbd> | **Toggle Wayle** | Oculta ou reexibe a barra Wayle |
| <kbd>SUPER</kbd> + <kbd>ALT</kbd> + <kbd>R</kbd> | **Recarregar Ambiente** | Recarrega Wayle, SwayNC e paletas do Matugen sem travar a sessão |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | **Seletor de Wallpaper** | Abre o menu de papéis de parede e dispara o Matugen |
| <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>W</kbd> | **Wallpaper Aleatório** | Troca o papel de parede e recalcula a paleta M3 em tempo real |
| <kbd>SUPER</kbd> + <kbd>D</kbd> | **Lançador de Aplicativos** | Rofi / Fuzzel estilizado com a paleta atual |
| <kbd>SUPER</kbd> + <kbd>Return</kbd> | **Terminal Kitty** | Terminal acelerado por GPU com cores dinâmicas |
| <kbd>SUPER</kbd> + <kbd>H</kbd> | **Cheat Sheet** | Exibe o menu com todos os atalhos disponíveis |

---

## 🏗️ Estrutura do Projeto

```
jakoolit-soberano/
├── config/
│   ├── hypr/
│   │   ├── configs/            # Configurações modulares do Hyprland em Lua
│   │   ├── scripts/            # Scripts de automação otimizados (sem polling agressivo)
│   │   │   ├── WayleStartup.sh # Lifecycle daemon do Wayle
│   │   │   ├── WayleLayout.sh  # Seletor interativo dos 47 presets
│   │   │   ├── WayleStyles.sh  # Seletor interativo de estilos SCSS/CSS
│   │   │   ├── MatugenSwww.sh  # Motor central de theming dinâmico Material You
│   │   │   └── Refresh.sh      # Recarregamento assíncrono suave
│   │   └── wayle/
│   │       ├── layouts/        # 47 presets convertidos para Wayle TOML
│   │       └── styles/         # Temas visuais (Matugen, Catppuccin, Glass, Cyber)
│   ├── matugen/
│   │   ├── config.toml         # Mapeamento de templates para todas as ferramentas
│   │   └── templates/          # Templates M3 (Hyprland, Kitty, Fuzzel, Rofi, Wayle, GTK)
│   └── wayle/                  # Configuração padrão ativa do Wayle
├── tools/
│   ├── soberano-cockpit-bar-rs # Dual-surface companion em Rust/GTK4
│   └── waybar_to_wayle_transpiler.py # Transpilador automatizado de Waybar para Wayle
├── copy.sh                     # Motor de implantação e backup
└── install-soberano.sh         # Script de instalação completa para VMs e bare-metal
```

---

## 🤝 Créditos e Reconhecimento

Este projeto é uma evolução direta construída sobre o trabalho pioneiro de:
- **JaKooLit / LinuxBeginnings**: Pelo design original dos layouts, scripts e dotfiles ([Hyprland-Dots](https://github.com/LinuxBeginnings/Hyprland-Dots)).
- **Comunidade Hyprland & Wayle**: Pelos projetos do compositor e da barra moderna em Rust.
- **Mantenedor do Fork**: [ViniciusPHDU20](https://github.com/ViniciusPHDU20).
