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
        
        # On Linux, skip cask installations (macOS GUI apps)
        # Note: brew bundle may fail on tap errors (deprecated taps) - this is expected and safe
        if [[ "$OS" == "Linux" ]]; then
            echo -e "${YELLOW}Note: Skipping cask installations on Linux${NC}"
            brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile" 2>&1 | grep -v "Skipping cask" || true
        else
            brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile" || true
        fi
        
        echo -e "${GREEN}✓ Packages installed${NC}"
        return 0  # Always succeed even if some packages failed
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
            echo -e "${YELLOW}Attempting to change default shell to zsh...${NC}"
            if chsh -s "$(which zsh)" 2>/dev/null; then
                echo -e "${GREEN}✓ Default shell changed to zsh${NC}"
            else
                echo -e "${YELLOW}⚠️  Could not change shell automatically (requires password)${NC}"
                echo -e "${YELLOW}   You can change it manually later with: chsh -s \$(which zsh)${NC}"
            fi
        else
            echo -e "${GREEN}✓ zsh is already the default shell${NC}"
        fi
    fi
    return 0  # Always succeed
}

# Set up mise
setup_mise() {
    echo -e "\n${BLUE}Setting up mise development environment...${NC}"
    
    if command_exists mise; then
        # Trust mise configuration (critical for symlinked configs in Coder)
        echo -e "${YELLOW}Trusting mise configuration...${NC}"
        
        # Trust ~/.config/mise first (the symlink location)
        mise trust "$HOME/.config/mise" 2>&1 || true
        
        # If config is a symlink, trust the actual target directory too
        local mise_config="$HOME/.config/mise/config.toml"
        if [ -L "$HOME/.config/mise" ] || [ -L "$mise_config" ]; then
            # Get the real path of the config directory or file
            local actual_path
            if [ -L "$HOME/.config/mise" ]; then
                actual_path=$(readlink -f "$HOME/.config/mise" 2>/dev/null || readlink "$HOME/.config/mise")
            else
                actual_path=$(readlink -f "$mise_config" 2>/dev/null || readlink "$mise_config")
                actual_path=$(dirname "$actual_path")
            fi
            
            if [ -n "$actual_path" ] && [ -d "$actual_path" ]; then
                echo -e "${YELLOW}Trusting actual config location: $actual_path${NC}"
                mise trust "$actual_path" 2>&1 || true
                
                # Also trust the config file directly
                if [ -f "$actual_path/config.toml" ]; then
                    mise trust "$actual_path/config.toml" 2>&1 || true
                fi
            fi
        fi
        
        # Install global tools
        echo -e "${YELLOW}Installing global Node.js LTS...${NC}"
        mise use -g node@lts 2>&1 || echo -e "${YELLOW}Could not install Node.js LTS, you can do this later with 'mise use -g node@lts'${NC}"
        
        # Install pnpm globally
        echo -e "${YELLOW}Installing global pnpm...${NC}"
        mise use -g pnpm@latest 2>&1 || echo -e "${YELLOW}Could not install pnpm, you can do this later with 'mise use -g pnpm@latest'${NC}"
        
        echo -e "${GREEN}✓ mise setup complete${NC}"
        echo -e "${YELLOW}Tip: Use 'mise use node@22' in projects to set specific versions${NC}"
    else
        echo -e "${YELLOW}mise not found, skipping global tool installation${NC}"
        echo -e "${YELLOW}Install mise manually: curl https://mise.run | sh${NC}"
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
    return 0  # Always succeed
}

# Run bootstrap script
run_bootstrap() {
    echo -e "\n${BLUE}Running bootstrap script to create symlinks...${NC}"
    chmod +x "$DOTFILES_DIR/bootstrap.sh"
    "$DOTFILES_DIR/bootstrap.sh"
    return 0  # Always succeed
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
        install_homebrew || echo -e "${YELLOW}Warning: Homebrew installation had issues (safe to ignore)${NC}"
        install_packages || echo -e "${YELLOW}Warning: Some packages may have failed (safe to ignore)${NC}"
    else
        echo -e "${YELLOW}Homebrew installation skipped (not macOS/Linux)${NC}"
    fi
    
    setup_shell || echo -e "${YELLOW}Warning: Shell setup incomplete${NC}"
    setup_git || echo -e "${YELLOW}Warning: Git setup incomplete${NC}"
    run_bootstrap || echo -e "${YELLOW}Warning: Bootstrap incomplete${NC}"
    setup_mise || echo -e "${YELLOW}Warning: mise setup incomplete${NC}"
    setup_macos || true  # Skip errors for non-macOS
    
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════╗"
    echo "║     Installation Complete! 🎉       ║"
    echo "╔══════════════════════════════════════╗"
    echo -e "${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Restart your terminal or run: source ~/.zshrc"
    echo -e "  2. Review and customize your dotfiles in: ${DOTFILES_DIR}"
    echo -e "  3. Update Git user info in ~/.gitconfig if needed"
    
    if command_exists mise; then
        echo -e "  4. Run 'mise doctor' to verify mise setup"
        echo -e "  5. Install global tools: mise use -g node@lts pnpm@latest"
        echo -e "  6. View global tasks: mise tasks"
    fi
    
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo -e "  ${YELLOW}⚠️  Run 'chsh -s \$(which zsh)' to set zsh as default shell${NC}"
    fi
    
    echo ""
    
    # For Coder environments: activate mise immediately and install tools
    if [ -n "$CODER" ] || [ -n "$CODER_WORKSPACE_NAME" ]; then
        echo -e "${BLUE}Detected Coder environment - activating mise now...${NC}"
        
        # Activate mise in current shell
        if command_exists mise; then
            eval "$(mise activate bash)" 2>/dev/null || true
            
            # Install global tools immediately (suppress all mise errors)
            echo -e "${YELLOW}Installing global Node.js and pnpm for immediate use...${NC}"
            mise use -g node@lts 2>&1 | grep -v -E "(^mise|Trust|trust|https://)" || true
            mise use -g pnpm@latest 2>&1 | grep -v -E "(^mise|Trust|trust|https://)" || true
            
            # Verify installation
            if mise which node >/dev/null 2>&1; then
                echo -e "${GREEN}✓ Node.js installed and ready: $(mise which node)${NC}"
            else
                echo -e "${YELLOW}⚠️  Node.js installation pending - will be available in new shells${NC}"
            fi
            if mise which pnpm >/dev/null 2>&1; then
                echo -e "${GREEN}✓ pnpm installed and ready: $(mise which pnpm)${NC}"
            else
                echo -e "${YELLOW}⚠️  pnpm installation pending - will be available in new shells${NC}"
            fi
        fi
    fi
    
    return 0  # Always return success to not break coder dotfiles
}

# Run main function
main
