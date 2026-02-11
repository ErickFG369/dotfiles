#!/bin/bash

# Instala o Stow se não existir
sudo apt update && sudo apt install -y stow

# Entra na pasta de dotfiles
cd "$(dirname "$0")"

# "Stow" em todas as pastas
stow kitty
stow fastfetch

echo "Configurações aplicadas com sucesso!"
