#!/usr/bin/env bash
#
# install.sh - Main installation script for dotfiles
#
# This script sets up a new machine with all necessary tools and configurations.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║     Dotfiles Installation Script    ║"
echo "╔══════════════════════════════════════╗"
echo -e "${NC}\n"

# Detect OS
OS="$(uname -s)"
echo -e "${BLUE}Detected OS: ${OS}${NC}\n"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew (macOS/Linux)
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this script
        if [[ "$OS" == "Darwin" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}✓ Homebrew already installed${NC}"
    fi
}

# Install packages from Brewfile
install_packages() {
    if [ -f "$DOTFILES_DIR/homebrew/Brewfile" ]; then
        echo -e "\n${YELLOW}Installing packages from Brewfile...${NC}"
        brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile"
        echo -e "${GREEN}✓ Packages installed${NC}"
    else
        echo -e "${YELLOW}No Brewfile found, skipping package installation${NC}"
    fi
}

# Set up shell
setup_shell() {
    echo -e "\n${BLUE}Setting up shell configuration...${NC}"
    
    # Check if zsh is installed and set as default
    if command_exists zsh; then
        if [[ "$SHELL" != *"zsh"* ]]; then
            echo -e "${YELLOW}Changing default shell to zsh...${NC}"
            chsh -s "$(which zsh)"
            echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
        else
            echo -e "${GREEN}✓ zsh is already the default shell${NC}"
        fi
    fi
}

# Set up mise
setup_mise() {
    echo -e "\n${BLUE}Setting up mise development environment...${NC}"
    
    if command_exists mise; then
        # Install global tools
        echo -e "${YELLOW}Installing global Node.js LTS...${NC}"
        mise use -g node@lts
        
        # Install pnpm globally
        echo -e "${YELLOW}Installing global pnpm...${NC}"
        mise use -g pnpm@latest
        
        echo -e "${GREEN}✓ mise setup complete${NC}"
        echo -e "${YELLOW}Tip: Use 'mise use node@22' in projects to set specific versions${NC}"
    else
        echo -e "${YELLOW}mise not found, skipping global tool installation${NC}"
    fi
}

# Set up Git
setup_git() {
    echo -e "\n${BLUE}Setting up Git configuration...${NC}"
    
    # Git config will be handled by symlinks
    if [ ! -f "$HOME/.gitconfig" ]; then
        echo -e "${YELLOW}Git config will be symlinked by bootstrap.sh${NC}"
    else
        echo -e "${GREEN}✓ Git configuration exists${NC}"
    fi
}

# Run bootstrap script
run_bootstrap() {
    echo -e "\n${BLUE}Running bootstrap script to create symlinks...${NC}"
    chmod +x "$DOTFILES_DIR/bootstrap.sh"
    "$DOTFILES_DIR/bootstrap.sh"
}

# macOS-specific settings
setup_macos() {
    if [[ "$OS" == "Darwin" ]]; then
        echo -e "\n${BLUE}Applying macOS-specific settings...${NC}"
        
        if [ -f "$DOTFILES_DIR/macos/defaults.sh" ]; then
            chmod +x "$DOTFILES_DIR/macos/defaults.sh"
            "$DOTFILES_DIR/macos/defaults.sh"
        else
            echo -e "${YELLOW}No macOS defaults script found${NC}"
        fi
    fi
}

# Main installation flow
main() {
    echo -e "${BLUE}Starting installation...${NC}\n"
    
    # macOS/Linux only
    if [[ "$OS" == "Darwin" ]] || [[ "$OS" == "Linux" ]]; then
        install_homebrew
        install_packages
    else
        echo -e "${YELLOW}Homebrew installation skipped (not macOS/Linux)${NC}"
    fi
    
    setup_shell
    setup_git
    run_bootstrap
    setup_mise
    setup_macos
    
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════╗"
    echo "║     Installation Complete! 🎉       ║"
    echo "╔══════════════════════════════════════╗"
    echo -e "${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Restart your terminal or run: source ~/.zshrc"
    echo -e "  2. Review and customize your dotfiles in: ${DOTFILES_DIR}"
    echo -e "  3. Update Git user info in ~/.gitconfig if needed\n"
}

# Run main function
main
