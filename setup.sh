#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Check if Homebrew is installed
check_homebrew() {
    print_info "Checking for Homebrew..."
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed!"
        print_error "Please install Homebrew first: https://brew.sh"
        exit 1
    fi
    print_success "Homebrew found"
}

# Install a package if not already installed
brew_install() {
    local package=$1
    if brew list "$package" &> /dev/null; then
        print_warning "$package is already installed, skipping"
    else
        print_info "Installing $package..."
        brew install "$package"
        print_success "$package installed"
    fi
}

# Install a cask if not already installed
brew_install_cask() {
    local cask=$1
    if brew list --cask "$cask" &> /dev/null; then
        print_warning "$cask is already installed, skipping"
    else
        print_info "Installing $cask..."
        brew install --cask "$cask"
        print_success "$cask installed"
    fi
}

# Main setup
main() {
    echo ""
    print_info "Starting dotfiles setup..."
    echo ""

    # Check for Homebrew
    check_homebrew
    echo ""

    # Update Homebrew
    print_info "Updating Homebrew..."
    brew update
    echo ""

    # Install core Neovim dependencies
    print_info "Installing core Neovim dependencies..."
    brew_install "neovim"
    brew_install "ripgrep"
    brew_install "fd"
    brew_install "node"
    brew_install "lazygit"
    echo ""

    # Install additional tools
    print_info "Installing additional development tools..."
    brew_install "tmux"
    brew_install "git"
    brew_install "make"
    echo ""

    # Install Nerd Font
    print_info "Installing Nerd Font..."
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Tapping homebrew/cask-fonts..."
        brew tap homebrew/cask-fonts
    fi
    brew_install_cask "font-meslo-lg-nerd-font"
    echo ""

    # Install TPM (Tmux Plugin Manager)
    print_info "Setting up Tmux Plugin Manager (TPM)..."
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ -d "$TPM_DIR" ]; then
        print_warning "TPM already installed, skipping"
    else
        print_info "Cloning TPM..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        print_success "TPM installed"
    fi
    echo ""

    # Claude
    print_info "Installing claude code"
    npm install -g @anthropic-ai/claude-code
    print_success "Claude code installed"

    # Success message
    print_success "Setup complete!"
}

# Run main function
main
