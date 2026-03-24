#!/usr/bin/env bash
set -e

# ==============================
#  CONFIGURAÇÕES
# ==============================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Removido fastfetch daqui para instalar a versão mais recente via função específica
CLI_PACKAGES=(curl git stow imagemagick wget)
FLATPAK_APPS=(
    com.visualstudio.code
    com.brave.Browser
    org.videolan.VLC
    com.xnview.XnViewMP
)

# ==============================
#  FUNÇÕES
# ==============================

log() {
    echo -e "${GREEN}==>${NC} $1"
}

warn() {
    echo -e "${YELLOW}==>${NC} $1"
}

error() {
    echo -e "${RED}Erro:${NC} $1"
    exit 1
}

detect_package_manager() {
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="install -y"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="-S --noconfirm"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="install -y"
    else
        error "Gerenciador de pacotes não suportado."
    fi
}

install_cli_packages() {
    log "Instalando dependências CLI..."
    if [ "$PKG_MANAGER" == "apt" ]; then
        sudo apt update
        sudo apt install -y "${CLI_PACKAGES[@]}" flatpak
    else
        sudo $PKG_MANAGER $INSTALL_CMD "${CLI_PACKAGES[@]}" flatpak
    fi
}

setup_flatpak() {
    if ! flatpak remote-list | grep -q flathub; then
        log "Adicionando Flathub..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        warn "Flathub já configurado."
    fi
}

install_flatpak_apps() {
    log "Instalando aplicativos Flatpak..."
    for app in "${FLATPAK_APPS[@]}"; do
        if ! flatpak list | grep -q "$app"; then
            flatpak install -y flathub "$app"
        else
            warn "$app já está instalado."
        fi
    done
}

install_fastfetch_latest() {
    if [ "$PKG_MANAGER" == "apt" ]; then
        if ! command -v fastfetch &> /dev/null; then
            log "Baixando versão mais recente do Fastfetch..."
            wget https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -O /tmp/fastfetch.deb
            sudo apt install -y /tmp/fastfetch.deb
            rm /tmp/fastfetch.deb
        fi
    else
        log "Instalando Fastfetch via gerenciador nativo..."
        sudo $PKG_MANAGER $INSTALL_CMD fastfetch
    fi
}

install_kitty() {
    if ! command -v kitty &> /dev/null; then
        log "Instalando Kitty..."
        curl -L -o kitty-installer.sh https://sw.kovidgoyal.net/kitty/installer.sh
        sh kitty-installer.sh
        rm kitty-installer.sh
        
        # Criar atalhos para o sistema reconhecer o Kitty
        mkdir -p ~/.local/bin
        ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
        ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/
    else
        warn "Kitty já instalado."
    fi
}

apply_dotfiles() {
    log "Aplicando dotfiles com GNU Stow..."
    cd "$DOTFILES_DIR"

    # Remove o .bashrc original para evitar conflito com o Stow
    if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
        warn "Removendo .bashrc original para aplicar dotfiles..."
        rm "$HOME/.bashrc"
    fi

    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != "bootstrap/" ]; then
            stow -v "${dir%/}"
        fi
    done
}

# ==============================
#  EXECUÇÃO
# ==============================

log "Iniciando setup universal do Erick..."

detect_package_manager
install_cli_packages
setup_flatpak
install_flatpak_apps
install_fastfetch_latest
install_kitty
apply_dotfiles

log "Setup concluído com sucesso!"
log "Reinicie o seu terminal ou sessão."
