#!/usr/bin/env bash

# Install Linux GUI applications and CLI tools

set -eo pipefail

# Load utilities
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SOURCE_DIR/lib/os.sh"

if ! is_linux; then
  echo "❌ Error: apps-linux.sh is only intended for Linux systems."
  exit 1
fi

# Ensure curl is available before downloading installers
if ! command -v curl &>/dev/null; then
  echo "📦 Installing curl..."
  sudo apt update
  sudo apt install -y curl
fi

echo "🚀 Installing Linux applications..."

if is_wsl; then
  echo "ℹ️  WSL environment detected — skipping Linux desktop GUI apps (Google Chrome, VS Code, Spotify)."
else
  # 1. Google Chrome
  if command -v google-chrome &>/dev/null; then
    echo "✅ Google Chrome is already installed."
  else
    echo "🌐 Installing Google Chrome..."
    TMP_CHROME="/tmp/google-chrome-stable_current_amd64.deb"
    curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$TMP_CHROME"
    sudo apt install -y "$TMP_CHROME"
    rm -f "$TMP_CHROME"
  fi

  # 2. Visual Studio Code
  if command -v code &>/dev/null; then
    echo "✅ Visual Studio Code is already installed."
  else
    echo "💻 Installing Visual Studio Code..."
    sudo apt install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/microsoft.gpg
    rm -f /tmp/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt update
    sudo apt install -y code
  fi
fi

# 3. Antigravity CLI (agy)
if command -v agy &>/dev/null; then
  echo "✅ Antigravity CLI (agy) is already installed."
else
  echo "🤖 Installing Antigravity CLI (agy)..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

# 4. Node.js (via nvm)
if [[ ! -d "$HOME/.nvm" && ! -d "$HOME/.config/nvm" ]]; then
  echo "📦 Installing nvm..."
  unset NVM_DIR
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh | bash
else
  echo "✅ nvm is already installed."
fi

# Set NVM_DIR for the current script session (needed below for corepack and loading nvm.sh)
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
else
  export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
fi

# Ensure corepack is automatically installed for any future Node.js versions
mkdir -p "$NVM_DIR"
if [ ! -f "$NVM_DIR/default-packages" ] || ! grep -qx "corepack" "$NVM_DIR/default-packages"; then
  echo "corepack" >> "$NVM_DIR/default-packages"
fi

# Load nvm in current session (temporarily disable set -e as nvm internals can return non-zero)
set +e
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi

if ! command -v nvm &>/dev/null; then
  echo "❌ Error: nvm could not be loaded."
  set -e
  exit 1
fi

# Download and install latest stable Node.js (LTS)
if ! nvm ls 'lts/*' &>/dev/null; then
  echo "🟢 Installing latest stable Node.js (LTS)..."
  nvm install --lts
else
  echo "✅ Node.js LTS is already installed."
fi

nvm use --lts
nvm alias default 'lts/*'

echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
set -e

# 5. pnpm (via Corepack)
if ! command -v corepack &>/dev/null; then
  npm install -g corepack
fi
corepack enable pnpm

if command -v pnpm &>/dev/null; then
  echo "✅ pnpm is installed and enabled ($(pnpm -v))."
fi

# 6. Spotify (desktop Linux only)
if ! is_wsl; then
  if command -v spotify &>/dev/null; then
    echo "✅ Spotify is already installed."
  else
    echo "🎵 Installing Spotify..."
    if ! command -v gpg &>/dev/null; then
      sudo apt update
      sudo apt install -y gpg
    fi
    curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
    sudo apt update
    sudo apt install -y spotify-client
  fi
fi

# 7. GitHub CLI (gh)
if command -v gh &>/dev/null; then
  echo "✅ GitHub CLI (gh) is already installed."
else
  echo "🐙 Installing GitHub CLI (gh)..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo mkdir -p -m 755 /etc/apt/sources.list.d
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
fi

# 8. SOPS (Secrets OPerationS) — installed from official GitHub releases
# See: https://github.com/getsops/sops/releases
if command -v sops &>/dev/null; then
  echo "✅ SOPS is already installed ($(sops --version 2>&1 | head -n 1))."
else
  echo "🔐 Installing SOPS..."
  SOPS_ARCH="$(dpkg --print-architecture)"
  SOPS_VERSION="$(curl -fsSL https://api.github.com/repos/getsops/sops/releases/latest | grep -oE '"tag_name":[[:space:]]*"[^"]+"' | head -n 1 | cut -d'"' -f4)"
  TMP_SOPS="$(mktemp)"
  curl -fsSL "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${SOPS_ARCH}" -o "$TMP_SOPS"
  sudo install -m 755 "$TMP_SOPS" /usr/local/bin/sops
  rm -f "$TMP_SOPS"
fi

echo "✨ Applications setup completed!"
