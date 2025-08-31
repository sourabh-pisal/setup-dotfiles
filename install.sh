#!/usr/bin/env bash
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect Linux distribution!"
    exit 1
fi

echo "Detected Linux distribution: $DISTRO"

install_prerequisites() {
    case "$DISTRO" in
        ubuntu|debian)
            echo "Updating and installing packages on Debian/Ubuntu"
            sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
            sudo apt install -y build-essential procps file git zsh
            ;;
        
        arch)
            echo "Updating and installing packages on Arch Linux"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm base-devel procps-ng file git zsh
            ;;
        
        fedora|rhel|centos)
            echo "Updating and installing packages on RHEL/Fedora/CentOS"
            if command -v dnf &> /dev/null; then
                sudo dnf upgrade --refresh -y
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y procps-ng file git zsh
            else
                sudo yum update -y
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y procps-ng file git zsh
            fi
            ;;
        
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

install_prerequisites

mkdir -p "$HOME/Workplace"
cd "$HOME/Workplace"

rm -rf "$HOME/Workplace/dotfiles"

git clone --bare https://github.com/sourabh-pisal/dotfiles.git "$HOME/Workplace/dotfiles"

alias dotfiles="/usr/bin/git --git-dir=$HOME/Workplace/dotfiles --work-tree=$HOME"

/usr/bin/git --git-dir="$HOME/Workplace/dotfiles" --work-tree="$HOME" switch -f mainline
/usr/bin/git --git-dir="$HOME/Workplace/dotfiles" --work-tree="$HOME" config --local status.showUntrackedFiles no

echo "Dotfiles setup completed successfully!"

