#!/bin/bash

# APT packages
echo "Which APT packages would you like to install?"
echo "Available packages:"
echo "1) curl"
echo "2) git" 
echo "3) flatpak"
echo "4) gnome-software-plugin-flatpak"
echo "5) build-essential"
echo "6) pkg-config"
echo "7) zsh"
echo "8) tmux"
echo "9) stow"
echo "10) fzf"
echo "11) eza"
echo ""
echo "Enter package numbers separated by space (e.g. 1 3 5)"
echo "Or enter 'all' to select all packages"
echo "Or press enter to skip"
read -r choices

packages=""
if [ "$choices" = "all" ]; then
    packages="curl git flatpak gnome-software-plugin-flatpak build-essential pkg-config zsh tmux stow fzf eza"
elif [ ! -z "$choices" ]; then
    for choice in $choices; do
        case $choice in
            1) packages="$packages curl";;
            2) packages="$packages git";;
            3) packages="$packages flatpak";;
            4) packages="$packages gnome-software-plugin-flatpak";;
            5) packages="$packages build-essential";;
            6) packages="$packages pkg-config";;
            7) packages="$packages zsh";;
            8) packages="$packages tmux";;
            9) packages="$packages stow";;
            10) packages="$packages fzf";;
            11) packages="$packages eza";;
        esac
    done
fi

if [ ! -z "$packages" ]; then
    sudo apt install -y $packages
fi

# Additional tools
read -p "Install tmux plugin manager (y/N)? " install_tpm
[[ $install_tpm =~ ^[Yy]$ ]] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

read -p "Install zoxide (y/N)? " install_zoxide
[[ $install_zoxide =~ ^[Yy]$ ]] && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

read -p "Install bun (y/N)? " install_bun
[[ $install_bun =~ ^[Yy]$ ]] && curl -fsSL https://bun.sh/install | bash

read -p "Install oh-my-zsh (y/N)? " install_omz
if [[ $install_omz =~ ^[Yy]$ ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    read -p "Install fzf-tab plugin (y/N)? " install_fzf_tab
    [[ $install_fzf_tab =~ ^[Yy]$ ]] && git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
    
    read -p "Install zsh-autosuggestions plugin (y/N)? " install_autosuggestions
    [[ $install_autosuggestions =~ ^[Yy]$ ]] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    
    read -p "Remove existing .zshrc (y/N)? " remove_zshrc
    [[ $remove_zshrc =~ ^[Yy]$ ]] && rm ~/.zshrc

    read -p "Set zsh as default shell (y/N)? " set_zsh_default
    if [[ $set_zsh_default =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        echo "Zsh has been set as your default shell. The change will take effect after you log out and back in."
    fi
fi

# Prompt for git config
read -p "Would you like to configure git user name and email? (y/N): " configure_git

if [[ $configure_git =~ ^[Yy]$ ]]; then
    read -p "Enter your git user name (or press enter to skip): " git_name
    if [[ ! -z "$git_name" ]]; then
        git config --global user.name "$git_name"
    fi

    read -p "Enter your git email (or press enter to skip): " git_email 
    if [[ ! -z "$git_email" ]]; then
        git config --global user.email "$git_email"
    fi
fi

