#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Attempting to install helpful packages..."
PLATFORM=$(uname)
if [[ "${PLATFORM}" = "Darwin" ]]; then
    if ! [ -x "$(command -v brew)" ]; then
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install ag git vim neovim tmux
elif [ -x "$(command -v apt)" ]; then
    sudo apt update
    sudo apt install -y \
        build-essential \
        git \
        silversearcher-ag \
        vim \
        neovim \
        tmux
fi

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
cp "${USER_HOME}"/.bash* "${BACKUP_FOLDER}/bashrc"

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
echo "Install the plugins by opening vim and running :PlugInstall"


source "${PWD}/.bashrc"
echo "Previous configuration was backed up in ${BACKUP_FOLDER}..."
exit 0

