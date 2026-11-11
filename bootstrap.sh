#!/usr/bin/env bash

# Symlink dotfiles from home/ into $HOME using GNU Stow.
# Compatible with both bash and zsh.

set -e

# Resolve the directory of the current script in both bash and zsh
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"
cd "$SOURCE_DIR" || exit 1

source "$SOURCE_DIR/lib/os.sh"

# Ensure GNU Stow is installed before attempting to symlink
if ! command -v stow &>/dev/null; then
  echo "⚠️  GNU Stow is required to symlink dotfiles, but it is not installed."
  if [[ "$1" == "--force" || "$1" == "-f" ]] || ask_yes_no "🔧 Run core.sh now to install mandatory prerequisites (including stow)?"; then
    bash "$SOURCE_DIR/core.sh"
  else
    echo "❌ Cannot continue without GNU Stow. Aborting."
    exit 1
  fi
fi

# Back up any existing files in $HOME that would conflict with files in home/
backup_conflicts() {
  local target="$1"
  local backup_dir="$target/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
  local backed_up=0

  while IFS= read -r src; do
    [[ -z "$src" ]] && continue
    local rel="${src#home/}"
    local dest="$target/$rel"

    # If destination exists (or is a broken symlink) and does not already point to src
    if [[ ( -e "$dest" || -L "$dest" ) && ! ( "$dest" -ef "$src" ) ]]; then
      if [[ $backed_up -eq 0 ]]; then
        echo "📦 Backing up existing conflicting dotfiles to $backup_dir..."
      fi
      mkdir -p "$(dirname "$backup_dir/$rel")"
      mv "$dest" "$backup_dir/$rel"
      echo "   Moved ~/$rel -> $backup_dir/$rel"
      backed_up=1
    fi
  done < <(find home -type f ! -name ".stow-local-ignore" ! -name "*.example*")
}

make_myself_at_home() {
  local target="$HOME"

  # Run a simulation first; if conflicts exist, automatically back them up
  # see: https://www.gnu.org/software/stow/manual/stow.html
  if ! stow --simulate -R -t "$target" home 2>/dev/null; then
    echo "⚠️  Conflicts detected in $target. Backing up existing files before stowing..."
    backup_conflicts "$target"

    # Re-run simulation to verify all conflicts were resolved
    if ! stow --simulate -R -t "$target" home 2>/dev/null; then
      echo "❌ Unresolved Stow conflicts remain:"
      stow --simulate --verbose -R -t "$target" home
      exit 1
    fi
  fi

  echo "✅ No conflicts. Setting up symlinks with Stow..."
  stow --verbose -R -t "$target" home

  # Reload shell if currently running inside zsh
  # Note: This affects the script's subshell; the user will still
  # need to run `source ~/.zshrc` in their main terminal once.
  if [[ -n "${ZSH_VERSION:-}" && -f ~/.zshrc ]]; then
    source ~/.zshrc
  fi

  echo "🎉 .dotfiles installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

MSG="Installing .dotfiles... 📋"

if [[ "$1" == "--force" || "$1" == "-f" ]]; then
  echo "$MSG (forced)"
  make_myself_at_home
else
  if ask_yes_no "This will symlink dotfiles into your home directory (existing files will be backed up to ~/.dotfiles-backup). Proceed?"; then
    echo "$MSG"
    make_myself_at_home
  else
    echo "Installation cancelled."
  fi
fi

# Clean up functions from the environment
unset -f make_myself_at_home backup_conflicts
