#!/usr/bin/env bash
#
# bootstrap.sh - Symlink dotfiles to home directory
#
# This script creates symlinks from the dotfiles repo to your home directory.
# It will backup existing files before creating symlinks.

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files to symlink (relative to dotfiles directory)
FILES=(
    ".bashrc"
    ".zshrc"
    ".bash_profile"
    ".gitconfig"
    ".gitignore_global"
)

# Config directories to symlink
CONFIG_DIRS=(
    ".config/mise"
)

# Directories to symlink
DIRS=(
    # Add directories here if needed
)

echo -e "${BLUE}Starting dotfiles bootstrap...${NC}"
echo -e "${BLUE}Dotfiles directory: ${DOTFILES_DIR}${NC}\n"

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}Created backup directory: ${BACKUP_DIR}${NC}\n"

# Function to backup and symlink a file
link_file() {
    local src="$1"
    local dest="$2"
    
    # Check if source file exists
    if [ ! -e "$src" ]; then
        echo -e "${YELLOW}Skipping ${dest} (source not found)${NC}"
        return
    fi
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${YELLOW}Backing up existing ${dest}${NC}"
        cp "$dest" "$BACKUP_DIR/"
        rm "$dest"
    elif [ -L "$dest" ]; then
        echo -e "${YELLOW}Removing existing symlink ${dest}${NC}"
        rm "$dest"
    fi
    
    # Create symlink
    echo -e "${GREEN}Creating symlink: ${dest} -> ${src}${NC}"
    ln -s "$src" "$dest"
}

# Symlink files
echo -e "${BLUE}Symlinking files...${NC}"
for file in "${FILES[@]}"; do
    link_file "$DOTFILES_DIR/$file" "$HOME/$file"
done

# Symlink directories
if [ ${#DIRS[@]} -gt 0 ]; then
    echo -e "\n${BLUE}Symlinking directories...${NC}"
    for dir in "${DIRS[@]}"; do
        link_file "$DOTFILES_DIR/$dir" "$HOME/$dir"
    done
fi

# Symlink config directories (create parent dirs if needed)
if [ ${#CONFIG_DIRS[@]} -gt 0 ]; then
    echo -e "\n${BLUE}Symlinking config directories...${NC}"
    for dir in "${CONFIG_DIRS[@]}"; do
        parent_dir="$(dirname "$HOME/$dir")"
        mkdir -p "$parent_dir"
        link_file "$DOTFILES_DIR/$dir" "$HOME/$dir"
    done
fi

echo -e "\n${GREEN}✓ Bootstrap complete!${NC}"
echo -e "${BLUE}Backup location: ${BACKUP_DIR}${NC}"

# Check if backup directory is empty
if [ -z "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "${YELLOW}No files were backed up. Removing empty backup directory.${NC}"
    rm -rf "$BACKUP_DIR"
fi

echo -e "\n${YELLOW}Remember to restart your shell or run 'source ~/.zshrc' (or ~/.bashrc)${NC}"
