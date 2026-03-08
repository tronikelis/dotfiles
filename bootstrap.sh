#!/bin/bash

set -eu

function is_executable {
    test -x "$(command -v "$1")"
}
function cdmktemp {
	cd "$(mktemp -d)"
}
cdmktemp

function setup_locale {
	LT_LOCALE="lt_LT.UTF-8 UTF-8"
	sudo sed -i "s/#$LT_LOCALE/$LT_LOCALE/" /etc/locale.gen
	sudo locale-gen
}

function setup_yay {
	if ! is_executable yay; then
		sudo pacman -S --needed git base-devel
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si

		yay -Y --gendb
		yay -Y --devel --save
	fi
}

function setup_pacman_configs {
	sudo sed -i 's/#Color/Color/' /etc/pacman.conf
	sudo sed -i 's/ debug / !debug /' /etc/makepkg.conf
}

function setup_chaoticaur {
	sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB

	sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

	if ! grep "chaotic-aur" /etc/pacman.conf &>/dev/null; then
sudo tee -a /etc/pacman.conf << EOF
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
	fi

	sudo pacman -Syu
}

function setup_packages {
	packages=(
		"docker"
		"git-delta"
		"bat"
		"rate-mirrors"
		"pacman-contrib"
		"neovim"
		"chaotic-aur/zen-browser-bin"
		"ufw"
		"less"
		"git"
		"man-db"
		"man-pages"
		"starship"
		"ripgrep"
		"fd"
		"fzf"
		"tmux"
		"stow"
		"kitty"
		"aur/xremap-kde-bin"
		"zsh"
		"eza"
		"tree-sitter-cli"
		"zoxide"
		"unzip"
		"go"
		"vivid"
		"chaotic-aur/vesktop"
		"wl-clipboard"
		"mpv"
		"gwenview"
	)
	yay -S "${packages[@]}" --noconfirm

	# docker setup
	sudo systemctl start docker
	sudo systemctl enable docker
	sudo groupadd docker &>/dev/null || true
	sudo usermod -aG docker "$USER"
}

function setup_paccache {
	sudo systemctl start paccache.timer
	sudo systemctl enable paccache.timer
}

function setup_firewall {
	sudo ufw enable
}

function setup_shell {
	chsh -s $(which zsh)
}

function setup_dotfiles {
	if [[ ! -e ~/dotfiles ]]; then
		git clone 'https://github.com/tronikelis/dotfiles.git' ~/dotfiles
	fi

	mkdir -p ~/.config/tmux
	mkdir -p ~/.local/bin
	~/dotfiles/bin/sync

	bat cache --build
}

function setup_xremap {

sudo tee /etc/systemd/system/xremap.service << EOF
[Unit]
Description=Xremap

[Service]
Type=simple
ExecStart=$(which xremap) --watch $HOME/.config/xremap/config.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

	sudo systemctl start xremap
	sudo systemctl enable xremap
}

function setup_tmux {
	mkdir -p ~/.tmux/plugins
	if [[ ! -e ~/.tmux/plugins/tpm ]]; then
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	fi
}

function setup_fonts {
	cdmktemp
	mkdir -p ~/.local/share/fonts

	curl -LO 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip'
	unzip 'NerdFontsSymbolsOnly.zip'
	cp *.ttf ~/.local/share/fonts

	curl -LO 'https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip'
	unzip "JetBrainsMono-2.304.zip"
	cp fonts/ttf/* ~/.local/share/fonts

	fc-cache -r
}

function setup_ratemirrors {
	sudo groupadd mirrorlistchangers || true
	sudo useradd --system --shell /usr/bin/nologin --home-dir / ratemirrors || true
	sudo usermod -a -G mirrorlistchangers ratemirrors

	sudo chown root:mirrorlistchangers /etc/pacman.d/mirrorlist
	sudo chmod 664 /etc/pacman.d/mirrorlist

sudo tee /etc/systemd/system/ratemirrors.service << EOF
[Unit]
Description=rate-mirrors

[Service]
User=ratemirrors
Type=oneshot
ExecStart=$(which bash) -c 'set -euo pipefail; sleep 600; tmp="\$(rate-mirrors --protocol https arch)"; tee /etc/pacman.d/mirrorlist <<<"\$tmp"'

[Install]
WantedBy=multi-user.target
EOF

	# sudo systemctl start ratemirrors
	sudo systemctl enable ratemirrors
}

function setup_gitconfig {
	if [[ ! -e ~/.gitconfig ]]; then
sudo tee -a ~/.gitconfig << EOF
[include]
	path = public.gitconfig

#[user]
#	email =
#	name =
#	signingkey =
#[gpg "ssh"]
#	program = ~/.config/git/scripts/ssh_program.sh
#	allowedSignersFile = ~/.ssh/git_allowed_signers
#[gpg]
#	format = ssh
EOF
	fi
}

setup_chaoticaur
setup_pacman_configs
setup_locale
setup_yay
setup_gitconfig

setup_packages

setup_tmux
setup_paccache
setup_firewall
setup_dotfiles
setup_shell
setup_xremap
setup_ratemirrors
setup_fonts
