=======
# dotfiles
# 🐧 Meus Dotfiles - Erick

Este repositório contém minhas configurações personalizadas para o ambiente Linux, organizadas com **GNU Stow** e automatizadas para facilitar a reinstalação em qualquer máquina.

## 🛠️ O que está incluído?
* **Kitty Terminal**: Configurações de performance, transparência e fontes (Geist Mono).
* **Fastfetch**: Layout personalizado com imagem estética e informações do sistema.
* **Automação**: Script de instalação que configura o sistema.

## 🚀 Como instalar em um novo sistema

Para replicar meu setup em uma instalação limpa do Ubuntu, basta seguir estes dois passos:

### 1. Clonar o repositório
Abra o terminal e baixe os arquivos para a sua pasta pessoal:
```bash
git clone [https://github.com/ErickFG369/dotfiles.git](https://github.com/ErickFG369/dotfiles.git) ~/dotfiles

---

### 2. Execute o Framework de Setup:

```Bash
cd ~/dotfiles
bash install.sh
