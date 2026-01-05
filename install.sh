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
)

for tool in "${CARGO_TOOLS[@]}"; do
    if cargo_pkg_installed "$tool"; then
        echo "✔ $tool already installed"
    else
        echo "➜ Installing $tool"
        cargo install "$tool"
    fi
done

# -----------------------------
# ESP Rust toolchain
# -----------------------------
if [ -f "$HOME/export-esp.sh" ]; then
    echo "✔ ESP Rust toolchain already installed"
else
    echo "Installing ESP Rust toolchain (espup)..."
    espup install
fi

# -----------------------------
# ESP-IDF install 
# -----------------------------
echo "Checking ESP-IDF in $ESP_IDF_DIR ..."

if [ -d "$ESP_IDF_DIR/.git" ]; then
    echo "✔ ESP-IDF already installed"
else
    echo "Installing ESP-IDF to filesystem..."
    mkdir -p "$ESP_BASE"
    cd "$ESP_BASE"

    git clone -b v5.1.2 --recursive https://github.com/espressif/esp-idf.git
fi

# -----------------------------
# Environment setup
# -----------------------------
echo "Configuring environment variables..."

if ! grep -q 'ESP_IDF_DIR=' "$HOME/.bashrc"; then
    cat <<EOF >> "$HOME/.bashrc"

# === ESP Rust + ESP-IDF  ===
export ESP_IDF_DIR="$ESP_IDF_DIR"
export IDF_PATH="$ESP_IDF_DIR"
[ -f "\$HOME/export-esp.sh" ] && source "\$HOME/export-esp.sh"
[ -f "\$ESP_IDF_DIR/export.sh" ] && source "\$ESP_IDF_DIR/export.sh"
EOF
    echo "✔ Environment added to ~/.bashrc"
else
    echo "✔ Environment already configured"
fi

# Apply env for current shell
export IDF_PATH="$ESP_IDF_DIR"
source "$HOME/export-esp.sh"
source "$ESP_IDF_DIR/export.sh"

# -----------------------------
# Verification
# -----------------------------
echo "=============================="
echo " Verifying installation "
echo "=============================="

echo "IDF_PATH = $IDF_PATH"

if command_exists ldproxy; then
    ldproxy --version
else
    echo "⚠ ldproxy not found"
fi

if command_exists idf.py; then
    idf.py --version
else
    echo "⚠ idf.py not found"
fi

echo "=============================="
echo " Setup completed successfully "
echo "=============================="
echo "Workspace location: $ESP_BASE"
echo "Restart terminal or run: source ~/.bashrc"
