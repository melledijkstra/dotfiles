#!/usr/bin/env bash

# Install Linux GUI applications and CLI tools (Google Chrome, VS Code, agy CLI)

set -e

# Load utilities
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SOURCE_DIR/lib/os.sh"

if ! is_linux; then
  echo "❌ Error: apps-linux.sh is only intended for Linux systems."
  exit 1
fi

echo "🚀 Installing Linux applications..."

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
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
  echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  sudo apt update
  sudo apt install -y code
fi

# 3. Antigravity CLI (agy)
if command -v agy &>/dev/null; then
  echo "✅ Antigravity CLI (agy) is already installed."
else
  echo "🤖 Installing Antigravity CLI (agy)..."
  curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

echo "✨ Applications setup completed!"
