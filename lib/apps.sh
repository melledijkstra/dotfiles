#!/usr/bin/env zsh

source "$DOTFILES/lib/os.sh"

quit_app() {
    local app_name=$1
    if [[ "$PLATFORM" == "macos" ]]; then
        echo "   Stopping $app_name..."
        osascript -e "quit app \"$app_name\"" 2>/dev/null || pkill -f "$app_name"
    elif [[ "$PLATFORM" == "linux" ]]; then
        echo "   Stopping $app_name..."
        pkill -f "$app_name" 2>/dev/null || true
    fi
}

open_browser_profile() {
    local profile=$1 # e.g. "Default", "Profile 1"
    local url=$2

    if [[ "$PLATFORM" == "macos" ]]; then
        # Check if Chrome is running with this profile by checking the SingletonLock in the profile directory
        local profile_dir="$HOME/Library/Application Support/Google/Chrome/$profile"

        # If SingletonLock exists, the profile is likely already open
        if [ -e "$profile_dir/SingletonLock" ]; then
            echo "   Chrome profile '$profile' is already open. Bringing to front..."
            # Use AppleScript to focus the windows of this profile (best effort)
            osascript -e "tell application \"Google Chrome\" to activate"

            # If a URL was provided, we might still want to open it in the existing window
            if [ -n "$url" ]; then
                 open -a "Google Chrome" --args --profile-directory="$profile" "$url"
            fi
        else
            echo "   Opening Chrome profile: $profile..."
            if [ -n "$url" ]; then
                open -na "Google Chrome" --args --profile-directory="$profile" "$url"
            else
                open -na "Google Chrome" --args --profile-directory="$profile"
            fi
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        local profile_dir="$HOME/.config/google-chrome/$profile"

        if [ -e "$profile_dir/SingletonLock" ]; then
            echo "   Chrome profile '$profile' is already open."
            if [ -n "$url" ]; then
                nohup google-chrome --profile-directory="$profile" "$url" >/dev/null 2>&1 &
            fi
        else
            echo "   Opening Chrome profile: $profile..."
            if [ -n "$url" ]; then
                nohup google-chrome --profile-directory="$profile" "$url" >/dev/null 2>&1 &
            else
                nohup google-chrome --profile-directory="$profile" >/dev/null 2>&1 &
            fi
        fi
    fi
}
