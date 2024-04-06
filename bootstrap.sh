#!/bin/bash

cd ~

# install yay

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
sudo sed -i -e "s/#Color/Color/" /etc/pacman.conf
cd ~

yay -Y --gendb


# install my used packages

packages=(
    "jdk-openjdk"
    "kdialog"
    "starship"
    "zoxide"
    "unp"
    "p7zip" 
    "unrar"
    "spectacle"
    "ripgrep"
    "fd"
    "fzf"
    "zenity"
    "trash-cli"
    "neofetch"
    "gnome-keyring"
    "signal-desktop"
    "firefox"
    "gwenview"
    "kimageformats"
    "qt6-imageformats"
    "zsh"
    "neovim"
    "unzip"
    "wl-clipboard"
    "noto-fonts"
    "noto-fonts-extra"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "kitty"
    "vlc"
    "go"
    "man-db"
    "man-pages"
    "ufw"
    "docker"
    "docker-compose"
    "partitionmanager"
    "dosfstools"
    "ntfs-3g"
)

yay -S "${packages[@]}" --noconfirm

yay -Y --devel --save

# firewall
sudo systemctl start ufw.service
sudo systemctl enable ufw.service
sudo ufw enable

# docker
sudo groupadd docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker $USER
sudo chmod +x $(where docker-compose)
sudo chgrp docker $(where docker-compose)

# oh my zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install --lts 
nvm alias default node 
corepack enable

# chaotic aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
 
printf "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# dotfiles

git clone https://github.com/Tronikelis/dotfiles.git ./.tdm
go install github.com/Tronikelis/tdm@v0.1.0

export PATH=${PATH}:`go env GOPATH`/bin
tdm sync

# fira code nerd font

mkdir -p "./.local/share/fonts/"
wget "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf" -P "./.local/share/fonts/"
fc-cache

# optional packages
# mailspring vesktop

# cleanup
rm -rf yay
