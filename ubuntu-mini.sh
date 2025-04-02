#!/bin/bash

# Exit on error
set -e

SCRIPT_DIR="$(pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"

echo "Starting system setup..."

# Update package lists
echo "Updating package lists..."
apt update

# Install required packages
echo "Installing packages: zsh screen zip unzip gdb valgrind fzf..."
apt install -y zsh screen zip unzip gdb valgrind fzf git curl

# Create directories
mkdir -p "${SCRIPT_DIR}/downloads"
mkdir -p "${CONFIG_DIR}/nvim"
mkdir -p "${CONFIG_DIR}/zsh"

# Install Neovim latest stable version
echo "Installing latest Neovim..."
cd "${SCRIPT_DIR}/downloads"
tar -xzf nvim-linux-x86_64.tar.gz -C "${SCRIPT_DIR}"
ln -sf "${SCRIPT_DIR}/nvim-linux-x86_64/bin/nvim" /usr/local/bin/nvim

# Set up LazyVim
echo "Setting up LazyVim..."
git clone https://github.com/LazyVim/starter "${CONFIG_DIR}/nvim"
rm -rf "${CONFIG_DIR}/nvim/.git"

# Create environment variable file to point to the config
cat >"${SCRIPT_DIR}/nvim_env.sh" <<EOF
export XDG_CONFIG_HOME="${CONFIG_DIR}"
export XDG_DATA_HOME="${CONFIG_DIR}/local/share"
export XDG_STATE_HOME="${CONFIG_DIR}/local/state"
export XDG_CACHE_HOME="${CONFIG_DIR}/cache"
EOF

# Set up Oh My Zsh
echo "Setting up Oh My Zsh..."
mkdir -p "${CONFIG_DIR}/zsh/oh-my-zsh"
git clone https://github.com/ohmyzsh/ohmyzsh.git "${CONFIG_DIR}/zsh/oh-my-zsh"

# Set up Powerlevel10k theme
echo "Setting up Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${CONFIG_DIR}/zsh/oh-my-zsh/custom/themes/powerlevel10k"

# Set up ZSH plugins
echo "Setting up ZSH plugins..."
mkdir -p "${CONFIG_DIR}/zsh/oh-my-zsh/custom/plugins"
cd "${CONFIG_DIR}/zsh/oh-my-zsh/custom/plugins"

# Download ZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions

# Create a custom .zshrc file
cat >"${SCRIPT_DIR}/zshrc" <<EOF
# Path to oh-my-zsh installation
export ZSH="${CONFIG_DIR}/zsh/oh-my-zsh"

# Set theme to powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(
  git
  zsh-autosuggestions
  command-not-found
  zsh-syntax-highlighting
  zsh-completions
)

# Load oh-my-zsh
source \$ZSH/oh-my-zsh.sh

# Enable command-not-found if available
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# ZSH completions setup
fpath=(\${ZSH}/custom/plugins/zsh-completions/src \$fpath)
autoload -Uz compinit
compinit
EOF

echo "Setup complete! To use this setup:"
echo "1. For Neovim with LazyVim: source ${SCRIPT_DIR}/nvim_env.sh && nvim"
echo "2. For ZSH with Oh My Zsh and Powerlevel10k: zsh --rcfile ${SCRIPT_DIR}/zshrc"
echo "Note: Configure Powerlevel10k by running 'p10k configure' after starting ZSH."
