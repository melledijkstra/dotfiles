#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Switch Context
# @raycast.mode silent
# @raycast.packageName Utils
# @raycast.icon 🔄

# @raycast.argument1 { "type": "text", "placeholder": "work/personal" }
# @raycast.argument2 { "type": "text", "placeholder": "close apps? (y/n)", "optional": true }

CONTEXT=$1
CLOSE_ARG=""

if [[ "$2" == "y" || "$2" == "yes" ]]; then
    CLOSE_ARG="--close"
fi

# Use the full path to ensure it works in Raycast environment
$HOME/.local/bin/switch-ctx "$CONTEXT" "$CLOSE_ARG"
