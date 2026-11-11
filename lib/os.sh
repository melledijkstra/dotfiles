#!/usr/bin/env bash
# Shared OS detection and interactive helpers (compatible with bash and zsh)

# Detect the Operating System
get_os() {
    local os_type="${OSTYPE:-$(uname -s | tr '[:upper:]' '[:lower:]')}"
    case "$os_type" in
        darwin*)               echo "macos" ;;
        linux*)                echo "linux" ;;
        msys*|cygwin*|mingw*)  echo "windows" ;;
        *)                     echo "unknown" ;;
    esac
}

export PLATFORM="$(get_os)"

# Helper to check if it's macOS
is_macos() {
    [[ "$(get_os)" == "macos" ]]
}

# Helper to check if it's Linux
is_linux() {
    [[ "$(get_os)" == "linux" ]]
}

# Helper to check if running inside Windows Subsystem for Linux (WSL)
is_wsl() {
    is_linux && [[ -f /proc/version ]] && grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null
}

# Helper to check if it's native Windows (Git Bash / MSYS / Cygwin)
is_windows() {
    [[ "$(get_os)" == "windows" ]]
}

# Helper to check if it's Ubuntu (or Ubuntu/Debian-based)
is_ubuntu() {
    is_linux && [[ -f /etc/os-release ]] && grep -qiE '^ID(_LIKE)?=.*(ubuntu|debian)' /etc/os-release
}

# Interactive y/n prompt compatible with both bash and zsh.
# Reads from /dev/tty when available so it works even when piped via `curl ... | bash`.
ask_yes_no() {
    local prompt="$1"
    local reply=""
    printf "%s (y/n): " "$prompt"
    if [[ -r /dev/tty ]]; then
        read -r reply < /dev/tty
    else
        read -r reply
    fi
    case "$reply" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}
