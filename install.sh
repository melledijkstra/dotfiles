#!/usr/bin/env bash

# Stop on error
set -e

echo "Pulling latest changes from GitHub... 🌐"
echo "This makes sure we have the latest updates to the dotfiles before we start installing."

git pull origin main;

# Load utilities
# Note: This assumes the script is run from within the repo or after cloning
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR"

# load simple utility functions for OS detection
source "$SOURCE_DIR/lib/os.sh"

# OS Validation
if ! is_macos && ! is_linux; then
    echo "❌ Error: This dotfiles setup only supports macOS and Linux (Ubuntu)."
    echo "Detected OS: $(get_os)"
    echo "Aborting installation."
    exit 1
fi

# Helpers
function ask_yes_no() {
    read -p "$1 (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "🚀 Starting Dotfiles Installation for $(get_os)..."

# Interactive Steps
if is_macos; then
    if ask_yes_no "📦 Install/Upgrade Homebrew packages (brew.sh)?"; then
        ./brew.sh
    fi
elif is_linux; then
    if ask_yes_no "📦 Install/Upgrade Ubuntu packages and Oh My Zsh (apt.sh)?"; then
        bash ./apt.sh
    fi

    if ask_yes_no "🖥️  Install Linux applications (Chrome, VS Code, agy CLI) (apps-linux.sh)?"; then
        bash ./apps-linux.sh
    fi
fi

if ask_yes_no "🔗 Sync dotfiles to home directory (bootstrap.sh)?"; then
    ./bootstrap.sh --force
fi

if is_macos; then
    if ask_yes_no "💻 Apply macOS system defaults (macos.sh)?"; then
        ./macos.sh
    fi
fi

echo "✨ Installation steps completed!"
echo "Note: Some changes may require a logout or restart to take effect."
