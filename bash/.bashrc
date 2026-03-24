# ~/.bashrc: executado pelo bash(1) para shells sem login.
# veja /usr/share/doc/bash/examples/startup-files (no pacote bash-doc)
# para exemplos

# Se não estiver rodando interativamente, não faça nada
case $- in
    *i*) ;;
      *) return;;
esac

# Histórico do shell
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Janela de terminal adaptável
shopt -s checkwinsize

# Cores e aliases básicos
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias lgrep='lgrep --color=auto'
fi

# Meus Aliases personalizados
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias install='sudo apt install'
alias update='sudo apt update && sudo apt upgrade -y'

# Habilitar preenchimento automático (Bash Completion)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ======================================================
# CONFIGURAÇÕES DE AMBIENTE (ERICK)
# ======================================================

# Adiciona binários locais ao PATH (Essencial para o Kitty e scripts)
export PATH="$HOME/.local/bin:$PATH"

# Executa o fastfetch apenas se ele estiver instalado
if command -v fastfetch &> /dev/null; then
    fastfetch
fi
