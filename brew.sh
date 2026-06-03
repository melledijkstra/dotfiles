#!/usr/bin/env bash

# Install essential applications & tools using Homebrew

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set up brew path for current session based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed."
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install from Brewfile
echo "Installing Homebrew packages from Brewfile... 🚀"

# > 💡 vital package for this dotfiles setup
# > `stow` is used for managing symlinks of dotfiles from the repository
# > to the home directory.
brew install stow

brew bundle install --file="./Brewfile"

# Add `gsha256sum` as `sha256sum` for compatibility with GNU tools.
# Part of `coreutils` installation (might be needed for gpg signing).
# ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# TODO: Move the below tools to the Brewfile and use `brew bundle` instead

# Install some other useful utilities like `sponge`.
# brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
# brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
# brew install gnu-sed --with-default-names

# Install `wget` with IRI support.
# brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
# brew install gnupg

# Install more recent versions of some macOS tools.
# brew install vim --with-override-system-vi
# brew install grep
# brew install openssh
# brew install screen
# brew install gmp

# Install font tools.
# brew tap bramstein/webfonttools
# brew install sfnt2woff
# brew install sfnt2woff-zopfli
# brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
# brew install aircrack-ng
# brew install bfg
# brew install binutils
# brew install binwalk
# brew install cifer
# brew install dex2jar
# brew install dns2tcp
# brew install fcrackzip
# brew install foremost
# brew install hashpump
# brew install hydra
# brew install john
# brew install knock
# brew install netpbm
# brew install nmap
# brew install pngcheck
# brew install socat
# brew install sqlmap
# brew install tcpflow
# brew install tcpreplay
# brew install tcptrace
# brew install ucspi-tcp # `tcpserver` etc.
# brew install xpdf
# brew install xz

# Install other useful binaries.
# brew install ack
# brew install exiv2
# brew install git
# brew install git-lfs
# brew install gs
# brew install imagemagick --with-webp
# brew install lua
# brew install lynx
# brew install p7zip
# brew install pigz
# brew install pv
# brew install rename
# brew install rlwrap
# brew install ssh-copy-id
# brew install tree
# brew install vbindiff
# brew install zopfli

# Remove outdated versions from the cellar.
brew cleanup

echo "Finished Homebrew setup! 🎉"

echo "Switching default shell to zsh... 🐚"
# Switch to using brew-installed zsh as default shell if it's not already the current shell.
if [ "$SHELL" != "$(which zsh)" ]; then
  # For m1 macs:
  chsh -s "$(which zsh)"
  # For intel macs:
  # chsh -s /usr/local/bin/zsh
  # macOS High Sierra and older:
  # chsh -s /bin/zsh
fi

# If you get an error for non-stadard shell you can try running first
# sudo sh -c "echo $(which zsh) >> /etc/shells"
