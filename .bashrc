# ~/.bashrc - Bash configuration

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR="code"
export VISUAL="code"

# History configuration
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# ============================================================================
# Path Configuration
# ============================================================================

# Homebrew (Apple Silicon)
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew (Intel)
if [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# mise - Development Environment Manager
# ============================================================================
# Replaces: nvm, asdf, pyenv, direnv, and more
# Manages: Node.js, Python, Go, Rust, and 100+ other tools
# See: https://mise.jdx.dev

# Activate mise (must come after PATH setup)
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# Legacy support - if you still have nvm installed
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ============================================================================
# Prompt Configuration
# ============================================================================

# Git branch in prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set prompt with colors
export PS1="\[\033[36m\]\w\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

# ============================================================================
# Aliases
# ============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# List files
alias ls="ls -G"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"

# Git shortcuts
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias glog="git log --oneline --graph --decorate"

# Docker shortcuts
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dim="docker images"

# Development shortcuts
alias ni="npm install"
alias nid="npm install --save-dev"
alias nr="npm run"
alias pi="pnpm install"
alias pr="pnpm run"

# mise shortcuts
alias mi="mise install"
alias mu="mise use"
alias ml="mise list"
alias mx="mise exec"
alias mw="mise watch"
alias mt="mise task run"
alias mr="mise run"

# VS Code
alias c="code"
alias c.="code ."

# System
alias reload="source ~/.bashrc"
alias editrc="code ~/.bashrc"

# Safe operations
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Quick directory navigation
alias work="cd ~/work"
alias dash="cd ~/Dashclicks"

# ============================================================================
# Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick find
qfind() {
    find . -name "$1"
}

# Git commit with message
gcm() {
    git commit -m "$1"
}

# Extract various archive types
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# Shell Options
# ============================================================================

# Enable bash completion
if [ -f /opt/homebrew/etc/bash_completion ]; then
    . /opt/homebrew/etc/bash_completion
fi

# ============================================================================
# Load local customizations (not tracked in git)
# ============================================================================

# Source local config if it exists (for machine-specific overrides)
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
