#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DOTFILES_REPO_FOLDER=$(mktemp -d)
PLATFORM=$(uname)

ensure_homebrew() {
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_packages() {
  if [[ "${PLATFORM}" = "Darwin" ]]; then
      ensure_homebrew
      echo "Installing packages: $@"
      brew install "$@"
  elif [ -x "$(command -v apt)" ]; then
      echo "Installing packages: $@"
      DEBIAN_FRONTEND=noninteractive sudo apt install -y "$@"
  elif [ -x "$(command -v apk)" ]; then
      echo "Installing packages: $@"
      sudo apk add -U --no-cache "$@"
  elif [ -x "$(command -v dnf)" ]; then
      echo "Installing packages: $@"
      sudo dnf install -y "$@"
  else
      echo "Cant install packages: couldn't find a supported package manager"
      exit 1
  fi
}

update_package_index() {
  if [ -x "$(command -v apt)" ]; then
    sudo apt update
  elif [ -x "$(command -v apk)" ]; then
    sudo apk update
  fi
}

install_neovim() {
  echo "===== NEOVIM: Cleaning existing configuration"
  rm -rf ~/.config/nvim
  rm -rf ~/.local/share/nvim
  rm -rf ~/.cache/nvim

  if [[ "${PLATFORM}" = "Darwin" ]]; then
    echo "===== NEOVIM: Installing via homebrew"
    brew install neovim
  else
    rm -rf ~/neovim
    echo "===== NEOVIM: Installing build dependencies"
    if [ -x "$(command -v apt)" ]; then
      install_packages ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
    elif [ -x "$(command -v dnf)" ]; then
      install_packages ninja-build gettext libtool autoconf automake cmake gcc-c++ pkgconfig unzip curl doxygen
    elif [ -x "$(command -v apk)" ]; then
      install_packages ninja gettext libtool autoconf automake cmake build-base pkgconf unzip curl doxygen
    fi

    echo "===== NEOVIM: Cloning GitHub repository"
    git clone https://github.com/neovim/neovim.git ~/neovim

    echo "===== NEOVIM: Building neovim"
    (
      cd ~/neovim
      make CMAKE_BUILD_TYPE=Release -j
      sudo make install
    )
  fi
}

install_nvm() {
  if [[ "${PLATFORM}" != "Darwin" ]]; then
    install_packages curl
  fi
  if [[ "${PLATFORM}" = "Linux" ]]; then
    install_packages xsel
  fi
  NVM_DIR=""
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)"

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  nvm install node
  nvm install-latest-npm
}

install_nerd_font() {
  if [[ "${PLATFORM}" = "Darwin" ]]; then
    NERD_FONT_FOLDER="$HOME/Library/Fonts"
  else
    NERD_FONT_FOLDER="$HOME/.local/share/fonts"
  fi
  mkdir -p "${NERD_FONT_FOLDER}"
  curl -fLO --output-dir "${NERD_FONT_FOLDER}" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
}

configure_nvim() {
  echo "===== copying custom nvim config"
  if [[ "${PLATFORM}" = "Darwin" ]]; then
    install_packages tree-sitter-cli
  else
    npm install -g tree-sitter-cli
  fi
  mkdir -p "${HOME}/.config"
  cp -r "${DOTFILES_REPO_FOLDER}/nvim" "${HOME}/.config/nvim"
}

install_zsh_oh_my_zsh() {
  echo "===== zsh & oh-my-zsh: Installing"
  install_packages zsh
  (
    cd "${DOTFILES_REPO_FOLDER}"
    ./zsh-install.sh \
        -t https://github.com/spaceship-prompt/spaceship-prompt \
        -p git \
        -p ssh-agent \
        -p history-substring-search \
        -p web-search \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/agkozak/zsh-z \
        -p https://github.com/zsh-users/zsh-completions \
        -p https://github.com/unixorn/fzf-zsh-plugin \
        -p https://github.com/zsh-users/zsh-syntax-highlighting
  )
  if [[ "${PLATFORM}" = "Darwin" ]]; then
    chsh -s "$(which zsh)"
  else
    sudo chsh "${USER}" -s "$(which zsh)"
  fi
}

clone_dotfiles_repo() {
  install_packages git
  echo "===== Custom scripts: Cloning 'dotfiles' GitHub repository"
  git clone https://github.com/jcapona/dotfiles.git "${DOTFILES_REPO_FOLDER}"
}

remove_dotfiles_repo() {
  rm -rf "${DOTFILES_REPO_FOLDER}"
}

copy_custom_scripts_and_aliases() {
  echo "===== Custom scripts: Copying shell aliases to user home folder"
  cp "${DOTFILES_REPO_FOLDER}"/shell_aliases ~/.shell_aliases

  echo "===== Custom scripts: Copying useful scripts to /usr/local/bin"
  sudo cp "${DOTFILES_REPO_FOLDER}"/scripts/* /usr/local/bin/

  echo "===== Updating zshrc"
  echo "[ -f ~/.shell_aliases ] && . ~/.shell_aliases" >> ~/.zshrc
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=$HOME/.local/bin:\$PATH" >> ~/.zshrc
}

install_and_configure_tmux() {
  echo "===== tmux: Installing tmux and configuration"
  install_packages tmux
  rm -rf ~/.tmux*
  # Install TPM plugin manager
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # Install catppuccin
  mkdir -p ~/.config/tmux/plugins/catppuccin
  git clone -b v2.1.2 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

  cp "${DOTFILES_REPO_FOLDER}"/tmux.conf ~/.tmux.conf
}

install_wezterm() {
  echo "===== wezterm: Installing wezterm and configuration"
  cp "${DOTFILES_REPO_FOLDER}"/wezterm.lua ~/.wezterm.lua
  if [ -x "$(command -v apt)" ]; then
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    install_packages wezterm-nightly
  elif [ -x "$(command -v dnf)" ]; then
    sudo dnf copr enable wezfurlong/wezterm-nightly
    install_packages wezterm
  elif [ -x "$(command -v brew)" ]; then
    brew tap wez/wezterm-linuxbrew
    install_packages wezterm
  fi
}


main() {
  clone_dotfiles_repo
  update_package_index
  install_neovim
  install_zsh_oh_my_zsh
  copy_custom_scripts_and_aliases
  install_and_configure_tmux
  install_nvm
  install_nerd_font
  configure_nvim
  remove_dotfiles_repo
}


main
