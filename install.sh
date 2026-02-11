#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}==> Iniciando a automação do sistema...${NC}"

# 1. Atualizar repositórios e instalar dependências básicas
echo -e "${GREEN}==> Instalando dependências (git, stow, fastfetch, etc)...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git stow fastfetch imagemagick

# 2. Instalar o Kitty Terminal (se não estiver instalado)
if [ ! -d "$HOME/.local/kitty.app" ]; then
    echo -e "${GREEN}==> Instalando Kitty Terminal...${NC}"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    
    # Desktop Integration (como fizemos no início)
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
fi

# 3. Aplicar as configurações usando o GNU Stow
echo -e "${GREEN}==> Aplicando configurações com GNU Stow...${NC}"
cd ~/dotfiles
stow kitty
stow fastfetch
stow bash

echo -e "${GREEN}==> Tudo pronto! Reinicie o seu terminal.${NC}"
