#!/bin/bash

USER_HOME="${HOME}"
VIM_CONFIG="${USER_HOME}/.vim"
BACKUP_FOLDER="${PWD}/backups"

if [ -d "${BACKUP_FOLDER}" ]; then
    echo "There's backed up files at ${BACKUP_FOLDER}, exiting..."
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
elif [ -f "${USER_HOME}/.vimrc" ]; then
    mv "${USER_HOME}/.vimrc" "${BACKUP_FOLDER}/vim"
elif [ -L "${USER_HOME}/.vimrc" ]; then
    rm "${USER_HOME}/.vimrc"
fi

# vim config mostly taken from https://github.com/humiaozuzu/dot-vimrc
echo "Copying new vim config to user home folder"
mkdir -p "${VIM_CONFIG}"
cp "${PWD}/vimrc" "${VIM_CONFIG}"
cp "${PWD}/bundles.vim" "${VIM_CONFIG}"
ln -s "${VIM_CONFIG}/vimrc" "${USER_HOME}/.vimrc"

echo "Cloning vundle plugin manager"
git clone https://github.com/gmarik/vundle.git "${VIM_CONFIG}/bundle/vundle"
echo "Open vim and run: ':BundleInstall'"

source "${PWD}/.bashrc"
exit 0

#sudo cp -fr scripts/* /usr/bin/
#
#sudo apt update
#sudo apt upgrade -y
#sudo apt install -y \
#    build-essential \
#    git \
#    silversearcher-ag \
#    strace \
#    vim \
#    vlc
