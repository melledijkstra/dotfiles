#!/usr/bin/env bash

# Install essential applications & tools on Ubuntu/Debian using apt

set -e

echo "📦 Updating apt package index and upgrading installed packages..."
sudo apt update
sudo apt upgrade -y

echo "🚀 Installing packages via apt..."

PACKAGES=(
  # Shell & Dotfiles management
  zsh
  stow
  curl

  # Git
  git
  git-lfs

  # File Processing
  ffmpeg
  gifsicle
  libimage-exiftool-perl

  # Development Tools
  golang-go
  jq
  libnss3-tools
  mkcert
  python3
  tree

  # Containers
  # docker.io # for now disabled
)

sudo apt install -y "${PACKAGES[@]}"

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "🐚 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# Install zsh-autosuggestions plugin if not already installed
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "🔌 Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "✅ zsh-autosuggestions already installed."
fi

# Clean up unused packages
sudo apt autoremove -y

echo "Finished apt setup! 🎉"

echo "Switching default shell to zsh... 🐚"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
ZSH_PATH="$(command -v zsh)"
if [[ -n "$ZSH_PATH" && "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH"
fi
