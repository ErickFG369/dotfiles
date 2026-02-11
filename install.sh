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

CLI_PACKAGES=(curl git stow fastfetch imagemagick)
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
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    else
        error "Gerenciador de pacotes não suportado."
    fi
}

install_cli_packages() {
    log "Instalando dependências CLI..."

    case $PKG_MANAGER in
        apt)
            sudo apt update
            sudo apt install -y "${CLI_PACKAGES[@]}" flatpak
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "${CLI_PACKAGES[@]}" flatpak
            ;;
        dnf)
            sudo dnf install -y "${CLI_PACKAGES[@]}" flatpak
            ;;
    esac
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

install_kitty() {
    if ! command -v kitty &> /dev/null; then
        log "Instalando Kitty..."
        curl -L -o kitty-installer.sh https://sw.kovidgoyal.net/kitty/installer.sh
        sh kitty-installer.sh
        rm kitty-installer.sh
    else
        warn "Kitty já instalado."
    fi
}

apply_dotfiles() {
    log "Aplicando dotfiles com GNU Stow..."
    cd "$DOTFILES_DIR"

    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != "bootstrap/" ]; then
            stow -v "${dir%/}"
        fi
    done
}

# ==============================
#  EXECUÇÃO
# ==============================

log "Iniciando setup universal..."

detect_package_manager
install_cli_packages
setup_flatpak
install_flatpak_apps
install_kitty
apply_dotfiles

log "Setup concluído com sucesso!"
log "Reinicie sua sessão se necessário."
