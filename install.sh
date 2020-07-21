#!/bin/bash

cp .* "/home/${USER}/"
source "/home/${USER}/.bashrc"

sudo cp -fr scripts/* /usr/bin/

sudo apt update
sudo apt upgrade -y
sudo apt install -y \
    build-essential \
    git \
    silversearcher-ag \
    strace \
    vim \
    vlc

