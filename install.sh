#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DOTFILES_REPO_FOLDER=$(mktemp -d)

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
  elif [ -x "$(command -v dnf)" ]; then
      PACKAGE_MANAGER_COMMAND="sudo dnf install -y"
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
  rm -rf ~/neovim

  echo "===== NEOVIM: Installing build dependencies"
  install_packages ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

  echo "===== NEOVIM: Cloning GitHub repository"
  git clone https://github.com/neovim/neovim.git ~/neovim
  cd ~/neovim

  echo "===== NEOVIM: Building neovim 0.9"
  git checkout release-0.9
  make CMAKE_BUILD_TYPE=Release -j
  #make CMAKE_EXTRA_FLAGS="-DCOMPILE_LUA=OFF -DCMAKE_INSTALL_PREFIX=$HOME/neovim" CMAKE_BUILD_TYPE=RelWithDebInfo -j
  sudo make install
}

install_nvm() {
  install_packages curl
  if [ "$(uname -s)" = "Linux" ]; then
    install_packages xsel
  fi
  NVM_DIR=""
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)"

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  nvm install node
  nvm install-latest-npm
}

install_lunar_vim_ide() {
  echo "===== LunarVim: installing dependencies"
  install_packages cargo git make python3-pip python3
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) << EOF
y
y
y
EOF
  cp "${DOTFILES_REPO_FOLDER}/config.lua" "${HOME}/.config/lvim"
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=$HOME/.local/bin:\$PATH" >> ~/.zshrc

  #install_packages xsel wl-clipboard ripgrep python3-pip python3-pynvim
  #rm -rf ~/.config/nvim/
  #echo "===== LunarVim: Cloning GitHub repository"
  #git clone https://github.com/LunarVim/nvim-basic-ide.git ~/.config/nvim
}

install_nerd_font() {
  NERD_FONT_FOLDER="$HOME/.local/share/fonts"
  rm -rf "${NERD_FONT_FOLDER}"
  mkdir -p "${NERD_FONT_FOLDER}"
  cd "${NERD_FONT_FOLDER}"
  curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
  cd -
}

configure_nvim() {
#   echo "===== NEOVIM: installing plugins"
#   nvim --headless +'autocmd User PackerComplete qall' +'PackerSync' || true

  echo "===== fonts: Installing fonts for nvim"
  TMP_FOLDER=$(mktemp -d)
  git clone https://github.com/ronniedroid/getnf.git "${TMP_FOLDER}"
  cd "${TMP_FOLDER}"
  ./install.sh
  cd -
  rm -rf "${TMP_FOLDER}"
}

install_zsh_oh_my_zsh() {
  echo "===== zsh & oh-my-zsh: Installing"
  install_packages zsh
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
  cd -
  sudo chsh "${USER}" -s $(which zsh)
}

clone_dotfiles_repo() {
  install_packages git
  echo "===== Custom scripts: Cloning 'dotfiles' GitHub repository"
  git clone https://github.com/jcapona/dotfiles.git  "${DOTFILES_REPO_FOLDER}"
}

remove_dotfiles_repo() {
  rm -rf "${DOTFILES_REPO_FOLDER}"
}

copy_custom_scripts_and_aliases() {
  cd "${DOTFILES_REPO_FOLDER}"
  echo "===== Custom scripts: Copying shell aliases to user home folder"
  cp "${PWD}"/shell_aliases ~/.shell_aliases
  echo "[ -f ~/.shell_aliases ] && . ~/.shell_aliases" >> ~/.zshrc
  echo "===== Custom scripts: Copying useful scripts to /usr/local/bin"
  sudo cp "${PWD}"/scripts/* /usr/local/bin/
  cd -
}

install_and_configure_tmux() {
  echo "===== tmux: Installing tmux and configuration"
  install_packages tmux
  rm -rf ~/.tmux*
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  cp tmux.conf ~/.tmux.conf
}

install_wezterm() {
  echo "===== wezterm: Installing wezterm and configuration"
  cp wezterm.lua ~/.wezterm.lua
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
  build_neovim
  install_zsh_oh_my_zsh
  copy_custom_scripts_and_aliases
  install_and_configure_tmux
  install_nvm
  install_lunar_vim_ide
  install_nerd_font
  configure_nvim
  # install_wezterm
  remove_dotfiles_repo
}


main

