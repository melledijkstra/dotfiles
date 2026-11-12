#!/usr/bin/env bash

# Sensible Ubuntu (GNOME) desktop defaults.
# Inspired by macos.sh — configures Nautilus, Ubuntu Dock, appearance,
# touchpad/keyboard, media handling, and privacy via `gsettings`.
#
# Tip: To discover any setting changed via the Ubuntu Settings GUI, run:
#   dconf watch /

set -eo pipefail

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SOURCE_DIR/lib/os.sh"

if ! is_ubuntu; then
  echo "❌ Error: ubuntu.sh is only intended for Ubuntu / Debian systems."
  exit 1
fi

if is_wsl; then
  echo "ℹ️  WSL environment detected — skipping Ubuntu desktop defaults."
  exit 0
fi

if ! command -v gsettings &>/dev/null; then
  echo "⚠️  gsettings not found — skipping Ubuntu desktop defaults."
  exit 0
fi

# Helper to safely apply a gsettings key only if the schema and key exist
gset() {
  local schema="$1"
  local key="$2"
  local value="$3"

  if gsettings describe "$schema" "$key" &>/dev/null; then
    gsettings set "$schema" "$key" "$value"
  else
    echo "   ℹ️  Skipping $schema $key (not available on this version)"
  fi
}

echo "💻 Applying Ubuntu (GNOME) desktop defaults..."

###############################################################################
# File Manager (Nautilus & GTK File Chooser)                                  #
###############################################################################

# Show hidden files (dotfiles) by default
gset org.gnome.nautilus.preferences show-hidden-files true
gset org.gtk.gtk4.Settings.FileChooser show-hidden true
gset org.gtk.Settings.FileChooser show-hidden true

# Sort folders before files
gset org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gset org.gtk.Settings.FileChooser sort-directories-first true

# Use list view by default instead of icon grid
gset org.gnome.nautilus.preferences default-folder-viewer "'list-view'"

# Allow expanding folders as a tree in list view
gset org.gnome.nautilus.list-view use-tree-view true

###############################################################################
# Ubuntu Dock & Workspaces                                                    #
###############################################################################

# Position dock on the bottom ('LEFT', 'BOTTOM', 'RIGHT')
gset org.gnome.shell.extensions.dash-to-dock dock-position "'BOTTOM'"

# Use compact dock style instead of full-width panel
gset org.gnome.shell.extensions.dash-to-dock extend-height false

# Set dock icon size in pixels (default is 48)
gset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36

# Keep dock fixed and disable auto-hide
gset org.gnome.shell.extensions.dash-to-dock dock-fixed true
gset org.gnome.shell.extensions.dash-to-dock autohide false

# Hide Trash and mounted drives from the dock
gset org.gnome.shell.extensions.dash-to-dock show-trash false
gset org.gnome.shell.extensions.dash-to-dock show-mounts true

# Clicking a running app icon in the dock minimizes or shows window previews
gset org.gnome.shell.extensions.dash-to-dock click-action "'minimize-or-previews'"

# Span workspaces across all monitors instead of primary monitor only
gset org.gnome.mutter workspaces-only-on-primary false

###############################################################################
# Appearance, Top Bar & Night Light                                           #
###############################################################################

# Enable Dark Mode system-wide
gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
gset org.gnome.desktop.interface gtk-theme "'Yaru-dark'"

# Show battery percentage in the top bar
gset org.gnome.desktop.interface show-battery-percentage true

# Top bar clock: 24-hour format and show weekday
gset org.gnome.desktop.interface clock-format "'24h'"
gset org.gnome.desktop.interface clock-show-weekday true
gset org.gnome.desktop.interface clock-show-seconds false

# Enable Night Light (warmer display colors in the evening)
gset org.gnome.settings-daemon.plugins.color night-light-enabled true

###############################################################################
# Touchpad, Mouse & Keyboard                                                  #
###############################################################################

# Touchpad: enable tap-to-click
gset org.gnome.desktop.peripherals.touchpad tap-to-click true

# Touchpad: enable natural scrolling
gset org.gnome.desktop.peripherals.touchpad natural-scroll true

# Touchpad: use two-finger tap for right-click
gset org.gnome.desktop.peripherals.touchpad click-method "'fingers'"

# Keyboard: faster key repeat rate & shorter initial delay
gset org.gnome.desktop.peripherals.keyboard delay 250
gset org.gnome.desktop.peripherals.keyboard repeat-interval 20

# Optional: remap Caps Lock to Escape
# gset org.gnome.desktop.input-sources xkb-options "['caps:escape']"

###############################################################################
# Media Handling, Privacy & Power                                             #
###############################################################################

# Do not automatically open folders or autorun when plugging in external drives/media
gset org.gnome.desktop.media-handling automount-open false
gset org.gnome.desktop.media-handling autorun-never true

# Automatically clean up Trash and temporary files older than 30 days
gset org.gnome.desktop.privacy remove-old-trash-files true
gset org.gnome.desktop.privacy remove-old-temp-files true
gset org.gnome.desktop.privacy old-files-age 30

# Dim/blank screen after 10 minutes (600 seconds) of inactivity
gset org.gnome.desktop.session idle-delay 600

echo "✨ Ubuntu desktop defaults applied!"
