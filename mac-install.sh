#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo " Rust + ESP-IDF Setup (macOS) "
echo "=============================="

# -----------------------------
# Path configuration
# -----------------------------
ESP_BASE="$HOME/esp"
ESP_IDF_DIR="$ESP_BASE/esp-idf"

# -----------------------------
# Detect shell config
# -----------------------------
if [[ "$SHELL" == */zsh ]]; then
  SHELL_RC="$HOME/.zshrc"
else
  SHELL_RC="$HOME/.bashrc"
fi

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
# Homebrew
# -----------------------------
echo "Checking Homebrew..."

if ! command_exists brew; then
  echo "➜ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon path
  if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "✔ Homebrew already installed"
fi

brew update

# -----------------------------
# Base dependencies
# -----------------------------
echo "Checking base packages..."

BREW_PACKAGES=(
  git
  curl
  cmake
  ninja
  pkg-config
  python
  llvm
)

for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    echo "✔ $pkg already installed"
  else
    echo "➜ Installing $pkg"
    brew install "$pkg"
  fi
done

# -----------------------------
# Rust installation
# -----------------------------
if ! command_exists rustc; then
  echo "➜ Installing Rust..."
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


echo "=============================="
echo " Setup completed successfully "
echo "=============================="
echo "Workspace: $ESP_BASE"
echo "Restart terminal or run: source $SHELL_RC"
