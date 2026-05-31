#!/bin/bash

# Detect OS
PLATFORM="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
fi

# Shared Config
WORK_DIR="$HOME/adidas"
PERSONAL_DIR="$HOME/projects"

WORK_CHROME_PROFILE="Profile 1"
PERSONAL_CHROME_PROFILE="Profile 2"
