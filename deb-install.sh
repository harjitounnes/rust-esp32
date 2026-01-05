#!/bin/bash
set -e

echo "=============================="
echo " Rust + ESP-IDF Setup Script "
echo "=============================="

# -----------------------------
# Path configuration (IMPORTANT)
# -----------------------------
ESP_BASE="$HOME/esp"
ESP_IDF_DIR="$ESP_BASE/esp-idf"

# -----------------------------
# Helper functions
# -----------------------------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

cargo_pkg_installed() {
    cargo install --list | grep -q "^$1 v"
}

# -----------------------------
# System update
# -----------------------------
echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

# -----------------------------
# Base dependencies
# -----------------------------
echo "Checking base packages..."

BASE_PACKAGES=(
    build-essential
    curl
    git
    pkg-config
    libssl-dev
    libudev1
    python3
    python3-pip
    python3-venv
)

for pkg in "${BASE_PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "✔ $pkg already installed"
    else
        echo "➜ Installing $pkg"
        sudo apt install -y "$pkg"
    fi
done

# -----------------------------
# Rust installation
# -----------------------------
if ! command_exists rustc; then
    echo "Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
else
    echo "✔ Rust already installed"
fi

source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' >> ~/.bashrc

rustc --version
cargo --version

# -----------------------------
# Cargo tools
# -----------------------------
echo "Checking cargo tools..."

CARGO_TOOLS=(
    cargo-generate
    cargo-espflash
    espup
    ldproxy
)


for tool in "${CARGO_TOOLS[@]}"; do
    if cargo_pkg_installed "$tool"; then
        echo "✔ $tool already installed"
    else
        echo "➜ Installing $tool"
        cargo install "$tool"
    fi
done

cd $HOME
espup install

source "$HOME/export-esp.sh"
echo 'source "$HOME/export-esp.sh"' >> ~/.bashrc


echo "=============================="
echo " Setup completed successfully "
echo "=============================="

echo "Restart terminal or run: source ~/.bashrc"
