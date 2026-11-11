#!/usr/bin/env bash

# Install and configure mandatory core prerequisites across macOS and Linux:
# - Xcode Command Line Tools & Homebrew (macOS)
# - Essential CLI prerequisites: git, curl, zsh, stow
# - Oh My Zsh & zsh-autosuggestions plugin
# - Default login shell set to zsh

set -e

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SOURCE_DIR/lib/os.sh"

echo "🔧 Checking core prerequisites for $(get_os)..."

if is_macos; then
  # 1. Ensure Xcode Command Line Tools are installed (required for git/compilers on fresh macOS)
  if ! xcode-select -p &>/dev/null; then
    echo "🛠️  Installing Xcode Command Line Tools..."
    xcode-select --install || true
    echo "⏳ Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    echo "✅ Xcode Command Line Tools installed."
  fi

  # 2. Ensure Homebrew is installed and loaded in PATH
  if ! command -v brew &>/dev/null; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    BREW_INSTALL_SCRIPT="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash -c "$BREW_INSTALL_SCRIPT"
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo "✅ Homebrew already installed."
  fi
elif ! is_linux; then
  echo "❌ Error: Unsupported operating system ($(get_os))."
  exit 1
fi

# 3. Ensure essential tools are installed (git, curl, zsh, stow)
CORE_PACKAGES=(git curl zsh stow)
MISSING_PKGS=()
for pkg in "${CORE_PACKAGES[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    MISSING_PKGS+=("$pkg")
  fi
done

if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
  echo "📦 Installing missing core packages (${MISSING_PKGS[*]})..."
  if is_macos; then
    brew install "${MISSING_PKGS[@]}"
  elif is_linux; then
    sudo apt update
    sudo apt install -y "${MISSING_PKGS[@]}"
  fi
else
  echo "✅ Core packages (${CORE_PACKAGES[*]}) already installed."
fi

# 4. Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "🐚 Installing Oh My Zsh..."
  OMZ_INSTALL_SCRIPT="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$OMZ_INSTALL_SCRIPT"
else
  echo "✅ Oh My Zsh already installed."
fi

# 5. Install zsh-autosuggestions plugin if not already installed
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "🔌 Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "✅ zsh-autosuggestions already installed."
fi

# 6. Switch default login shell to zsh if needed
ZSH_PATH="$(command -v zsh || true)"
if [[ -n "$ZSH_PATH" ]]; then
  if is_macos; then
    CURRENT_SHELL="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
  else
    CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
  fi
  CURRENT_SHELL="${CURRENT_SHELL:-$SHELL}"

  if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    echo "🐚 Switching default shell to $ZSH_PATH..."
    # Ensure target zsh is listed in /etc/shells (important for Homebrew zsh on macOS)
    if [[ -f /etc/shells ]] && ! grep -qx "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH"
  else
    echo "✅ Default shell is already zsh ($ZSH_PATH)."
  fi
fi

echo "✨ Core prerequisites ready!"
