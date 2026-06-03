#!/usr/bin/env bash

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

# Helper to check if it's macOS
function is_macos() {
    [[ "$(get_os)" == "macos" ]]
}
