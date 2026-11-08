#!/usr/bin/env zsh

# Detect the Operating System
function get_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        msys*)    echo "windows" ;;
        cygwin*)  echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

export PLATFORM=$(get_os)

# Helper to check if it's macOS
function is_macos() {
    [[ "$(get_os)" == "macos" ]]
}

# Helper to check if it's Linux
function is_linux() {
    [[ "$(get_os)" == "linux" ]]
}

# Helper to check if it's Ubuntu (or Ubuntu-based)
function is_ubuntu() {
    is_linux && [[ -f /etc/os-release ]] && grep -qiE '^ID(_LIKE)?=.*ubuntu' /etc/os-release
}
