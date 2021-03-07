#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Attempting to install useful packages..."
PACKAGES_BASE="git vim neovim tmux curl wget less python3"
PACKAGES_OSX="ag"
PACKAGES_LINUX="python3-dev"
PACKAGES_TO_INSTALL=""
PACKAGE_MANAGER_COMMAND=""
PLATFORM=$(uname)
if [[ "${PLATFORM}" = "Darwin" ]]; then
    if ! [ -x "$(command -v brew)" ]; then
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PACKAGE_MANAGER_COMMAND="brew install"
    PACKAGES_TO_INSTALL="${PACKAGES_BASE} ${PACKAGES_OSX}"
elif [ -x "$(command -v apt)" ]; then
    PACKAGE_MANAGER_COMMAND="apt update && apt install -y"
    PACKAGES_LINUX="${PACKAGES_LINUX} silversearcher-ag"
    PACKAGES_TO_INSTALL="${PACKAGES_BASE} ${PACKAGES_LINUX}"
elif [ -x "$(command -v apk)" ]; then
    PACKAGE_MANAGER_COMMAND="apk update && apk add -U --no-cache"
    PACKAGES_LINUX="${PACKAGES_LINUX} the_silver_searcher"
    PACKAGES_TO_INSTALL="${PACKAGES_BASE} ${PACKAGES_LINUX}"
else
    echo "Couldn't install packages: couldn't find a supported package manager"
fi

eval "${PACKAGE_MANAGER_COMMAND} ${PACKAGES_TO_INSTALL}"

echo "Creating temporal folder to clone repo..."
TMP_FOLDER=$(mktemp -d)
cd "${TMP_FOLDER}"

echo "Cloning dotfiles repo..."
git clone https://github.com/jcapona/dotfiles.git
cd "dotfiles"

USER_HOME="${HOME}"
VIM_CONFIG="${USER_HOME}/.vim"
BACKUP_FOLDER="${PWD}/backups"

if [ -d "${BACKUP_FOLDER}" ]; then
    echo "There are backed up files at ${BACKUP_FOLDER}, please remove them and run this script again. Exiting..."
    exit 1
fi

echo "Creating backups folder..."
mkdir -p "${BACKUP_FOLDER}"

echo "Backing up bashrc files..."
mkdir "${BACKUP_FOLDER}/bashrc"
cp "${USER_HOME}"/.bash* "${BACKUP_FOLDER}/bashrc" || true

echo "Copying new bash config files to user home folder"
cp "${PWD}"/.bash* "${USER_HOME}"

echo "Backing up vim files"
mkdir "${BACKUP_FOLDER}/vim"
if [ -d "${VIM_CONFIG}" ]; then
    mv "${VIM_CONFIG}" "${BACKUP_FOLDER}/vim"
fi
if [ -f "${USER_HOME}/.vimrc" ]; then
    mv "${USER_HOME}/.vimrc" "${BACKUP_FOLDER}/vim"
elif [ -L "${USER_HOME}/.vimrc" ]; then
    rm "${USER_HOME}/.vimrc"
fi

echo "Copying new vim config to user home folder"
mkdir -p "${VIM_CONFIG}"
cp -r "${PWD}/vim/vim/"* "${VIM_CONFIG}"
cp -r "${PWD}/vim/vimrc" "${VIM_CONFIG}"
ln -s "${VIM_CONFIG}/vimrc" "${USER_HOME}/.vimrc"

echo "Installing vim plugin manager"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir -p ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim --headless +PlugInstall +qall


source "${PWD}/.bashrc"
echo "Previous configuration was backed up in ${BACKUP_FOLDER}..."
exit 0

