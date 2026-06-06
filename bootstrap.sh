#!/usr/bin/env zsh

# Get the directory of the current script
# ${0:A} is a Zsh modifier: A (Absolute path)
cd "$(dirname "${0:A}")" || exit 1;

function make_myself_at_home() {
  local target="$HOME";

  # Run a simulation first and capture errors
  # see: https://www.gnu.org/software/stow/manual/stow.html
  if ! stow --simulate -R -t "$target" home 2>/dev/null; then
      echo "⚠️  Conflicts detected! Real files already exist in your home directory."
      echo "Stow will not overwrite them. Please back them up (e.g., mv .zshrc .zshrc.bak) and try again."
      # Run again visible so they see which files
      stow --simulate --verbose -R -t "$target" home
      exit 1
  fi

  echo "✅ No conflicts. Setting up symlinks with Stow..."
  stow --verbose -R -t "$target" home

  # give some time to setup symlinks
  sleep 1;
	# Reload shell
  # Note: This affects the script's subshell; the user will still
  # need to run `source ~/.zshrc` in their main terminal once.
  [[ -f ~/.zshrc ]] && source ~/.zshrc

  echo "🎉 .dotfiles installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

MSG="Installing .dotfiles... 📋"

if [[ "$1" == "--force" || "$1" == "-f" ]]; then
  echo "$MSG (forced)"
	make_myself_at_home
else
	# Zsh-native read: -q (query 1 char, returns true/false if y/Y)
  if read -q "REPLY?This may overwrite existing files in your home directory. Are you sure? (y/n) "; then
    echo "" # Add newline after the (y/n) input
    echo "$MSG"
    make_myself_at_home
  else
    echo "\nInstallation cancelled."
  fi
fi;

# Clean up function from the environment
unfunction make_myself_at_home;
