# Dotfiles

Repositório contendo meus **dotfiles universais** e script de bootstrap para configurar rapidamente um ambiente Linux em:

- Ubuntu / Debian
- Arch Linux
- Fedora

O objetivo é ter um ambiente **reprodutível, portátil e modular**.

---

## 📦 O que este repositório configura

### 🔹 CLI Tools
- curl
- git
- stow
- fastfetch
- imagemagick

### 🔹 Terminal
- Kitty

### 🔹 Aplicações (via Flatpak)
- Visual Studio Code
- Brave Browser
- VLC
- XnView MP

### 🔹 Configurações
- Bash
- Kitty
- Fastfetch

---

## 🚀 Instalação

Clone o repositório:

```bash
git clone https://github.com/ErickFG369/dotfiles.git
cd dotfiles
Dê permissão de execução:

chmod +x install.sh
Execute:

./install.sh
🧠 Como funciona
O script:

Detecta automaticamente o gerenciador de pacotes (apt, pacman, dnf)

Instala dependências CLI

Instala e configura o Flatpak (se necessário)

Instala aplicações gráficas via Flathub

Instala Kitty (se não estiver presente)

Aplica os dotfiles usando GNU Stow

🧩 Estrutura do Repositório
dotfiles/
│
├── install.sh
├── bash/
├── kitty/
├── fastfetch/
Cada diretório é aplicado automaticamente via GNU Stow.

🔧 Modo Minimal (Opcional Futuro)
O script poderá ser executado em modo minimal para ambientes de servidor:

./install.sh --minimal
Isso instalará apenas ferramentas CLI e aplicará os dotfiles, sem instalar aplicativos gráficos.

🛡️ Filosofia do Projeto
Portabilidade entre distros

Sem dependência de ambiente gráfico específico

Modular e extensível

Reprodutível em novas máquinas

📌 Requisitos
Conexão com a internet

Permissão sudo

Sistema Linux compatível

📜 Licença
Uso pessoal. Livre para adaptação.
