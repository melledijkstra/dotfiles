#!/usr/bin/env bash

# Stop on error
set -e

# Load utilities
# Note: This assumes the script is run from within the repo or after cloning
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR"

# load simple utility functions for OS detection
source "$SOURCE_DIR/lib/os.sh"

# OS Validation
if ! is_macos; then
    echo "❌ Error: This dotfiles setup is currently only optimized for macOS."
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

echo "🚀 Starting Dotfiles Installation..."

# Interactive Steps
if ask_yes_no "📦 Install/Upgrade Homebrew packages (brew.sh)?"; then
    ./brew.sh
fi

if ask_yes_no "🔗 Sync dotfiles to home directory (bootstrap.sh)?"; then
    ./bootstrap.sh --force
fi

if ask_yes_no "💻 Apply macOS system defaults (.macos)?"; then
    ./.macos
fi

echo "✨ Installation steps completed!"
echo "Note: Some changes may require a logout or restart to take effect."
