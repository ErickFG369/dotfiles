#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}==> Iniciando a automação do sistema...${NC}"

# 1. Detecção do Gerenciador de Pacotes e instalação de dependências
if [ -x "$(command -v apt)" ]; then
    echo -e "${GREEN}==> Sistema baseado em Debian/Ubuntu detectado...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl git stow fastfetch imagemagick
elif [ -x "$(command -v pacman)" ]; then
    echo -e "${GREEN}==> Sistema baseado em Arch Linux detectado...${NC}"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm curl git stow fastfetch imagemagick
else
    echo -e "${RED}Erro: Gerenciador de pacotes não suportado!${NC}"
    exit 1
fi

# 2. Instalar o Kitty Terminal (se não estiver instalado)
if [ ! -d "$HOME/.local/kitty.app" ]; then
    echo -e "${GREEN}==> Instalando Kitty Terminal...${NC}"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    
    # Desktop Integration
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
