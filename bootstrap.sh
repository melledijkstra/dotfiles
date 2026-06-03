#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

echo "Pulling latest changes from GitHub... 🌐"
echo "This makes sure we have the latest updates to the dotfiles before we start installing."
git pull origin main;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	source ~/.zshrc;
}

MSG="Installing .dotfiles... 📋"

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  echo "$MSG (forced)"
	# doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$MSG"
		# doIt;
	fi;
fi;
unset doIt;
