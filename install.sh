#!/usr/bin/env bash
set -euo pipefail

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
    if command -v kitty &> /dev/null; then
        warn "Kitty já instalado ($(kitty --version 2>/dev/null | head -1))."
        return 0
    fi

    log "Instalando Kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

    # Criar atalhos para o sistema reconhecer o Kitty
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
    ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/

    # Adicionar entrada no menu de aplicativos
    mkdir -p ~/.local/share/applications ~/.local/share/icons
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/ 2>/dev/null || true
    cp ~/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png ~/.local/share/icons/ 2>/dev/null || true
    sed -i "s|Icon=kitty|Icon=$HOME/.local/share/icons/kitty.png|g" ~/.local/share/applications/kitty.desktop 2>/dev/null || true
}

apply_dotfiles() {
    log "Aplicando dotfiles com GNU Stow..."
    cd "$DOTFILES_DIR"

    # Faz backup do .bashrc original em vez de deletar (segurança)
    if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
        warn "Fazendo backup do .bashrc original em ~/.bashrc.bak..."
        cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
        rm "$HOME/.bashrc"
    fi

    # Lista explícita de pacotes Stow (evita processar pastas não-dotfiles no futuro)
    STOW_PACKAGES=(bash kitty fastfetch)

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            log "Aplicando: $pkg"
            # --no-folding garante que pastas existentes (.config/kitty) não sejam substituídas por symlinks
            stow -v --no-folding "$pkg" 2>&1 || {
                warn "Conflito ao aplicar '$pkg'. Tentando restow..."
                stow -v --no-folding --restow "$pkg" 2>&1 || warn "Não foi possível aplicar '$pkg'. Verifique conflitos manualmente."
            }
        else
            warn "Pasta '$pkg' não encontrada, pulando..."
        fi
    done

    # Aviso sobre current-theme.conf do Kitty (não está no repositório)
    if [ ! -f "$HOME/.config/kitty/current-theme.conf" ]; then
        warn "Tema do Kitty não encontrado. Execute dentro do Kitty:"
        warn "  kitten themes"
        warn "E escolha 'Tokyo Night' para aplicar o tema."
    fi
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
