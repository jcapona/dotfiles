#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


install_packages() {
  PACKAGE_MANAGER_COMMAND=""

  PLATFORM=$(uname)
  if [[ "${PLATFORM}" = "Darwin" ]]; then
      if ! [ -x "$(command -v brew)" ]; then
          echo "Installing homebrew..."
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      PACKAGE_MANAGER_COMMAND="brew install"
  elif [ -x "$(command -v apt)" ]; then
      PACKAGE_MANAGER_COMMAND="sudo apt update && DEBIAN_FRONTEND=noninteractive sudo apt install -y"
  elif [ -x "$(command -v apk)" ]; then
      PACKAGE_MANAGER_COMMAND="sudo apk update && sudo apk add -U --no-cache"
  else
      echo "Cant install packages: couldn't find a supported package manager"
      exit 1
  fi

  echo "Installing packages: $@"
  eval "${PACKAGE_MANAGER_COMMAND}" "$@"
}

build_neovim() {
  echo "===== NEOVIM: Cleaning existing configuration"
  rm -rf ~/.config/nvim
  rm -rf ~/.local/share/nvim
  rm -rf ~/.cache/nvim

  echo "===== NEOVIM: Installing build dependencies"
  install_packages ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen git

  echo "===== NEOVIM: Cloning GitHub repository"
  git clone https://github.com/neovim/neovim.git ~/neovim
  cd ~/neovim

  echo "===== NEOVIM: Building neovim 0.8"
  git checkout release-0.8
  make CMAKE_BUILD_TYPE=Release -j
  #make CMAKE_EXTRA_FLAGS="-DCOMPILE_LUA=OFF -DCMAKE_INSTALL_PREFIX=$HOME/neovim" CMAKE_BUILD_TYPE=RelWithDebInfo -j
  sudo make install
}

install_lunar_vim_ide() {
  echo "===== LunarVim: installing dependencies"
  install_packages xsel wl-clipboard ripgrep python3-pip npm
  pip3 install pynvim

  echo "===== LunarVim: Cloning GitHub repository"
  git clone https://github.com/LunarVim/nvim-basic-ide.git ~/.config/nvim
}


configure_nvim() {
  echo "===== NEOVIM: installing plugins"
  nvim --headless +'autocmd User PackerComplete qall' +'PackerSync' || true

  echo "===== fonts: Installing fonts for nvim"
  TMP_FOLDER=$(mktemp -d)
  git clone https://github.com/ronniedroid/getnf.git "${TMP_FOLDER}"
  cd "${TMP_FOLDER}"
  ./install.sh
  cd -
  rm -r "${TMP_FOLDER}"
}

install_zsh_oh_my_zsh() {
  echo "===== zsh & oh-my-zsh: Installing"
  install_packages wget

  sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)" -- \
      -p git \
      -p ssh-agent \
      -p 'history-substring-search' \
      -p https://github.com/zsh-users/zsh-autosuggestions \
      -p https://github.com/agkozak/zsh-z
}

copy_custom_scripts_and_aliases() {
  echo "===== Custom scripts: Cloning 'dotfiles' GitHub repository"
  TMP_FOLDER=$(mktemp -d)
  git clone https://github.com/jcapona/dotfiles.git  "${TMP_FOLDER}"
  cd "${TMP_FOLDER}"

  echo "===== Custom scripts: Copying shell aliases to user home folder"
  cp "${PWD}"/shell_aliases ~/.shell_aliases
  echo "[ -f ~/.shell_aliases ] && . ~/.shell_aliases" >> ~/.zshrc
  echo "===== Custom scripts: Copying useful scripts to /usr/local/bin"
  cp "${PWD}"/scripts/* /usr/local/bin/

  cd -
  rm -r "${TMP_FOLDER}"
}

install_and_configure_tmux() {
  echo "===== tmux: Installing tmux and configuration"
  install_packages tmux
  git clone https://github.com/gpakosz/.tmux.git ~/.tmux
  ln -s -f .tmux/.tmux.conf
}


main() {
  build_neovim
  install_lunar_vim_ide
  configure_nvim
  install_zsh_oh_my_zsh
  copy_custom_scripts_and_aliases
  install_and_configure_tmux
  exit 0
}


main

