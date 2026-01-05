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
if [[ -f "$HOME/export-esp.sh" ]]; then
  echo "✔ ESP Rust toolchain already installed"
else
  echo "➜ Installing ESP Rust toolchain (espup)..."
  espup install
fi

# -----------------------------
# ESP-IDF install
# -----------------------------
echo "Checking ESP-IDF in $ESP_IDF_DIR ..."

if [[ -d "$ESP_IDF_DIR/.git" ]]; then
  echo "✔ ESP-IDF already installed"
else
  echo "➜ Installing ESP-IDF..."
  mkdir -p "$ESP_BASE"
  cd "$ESP_BASE"
  git clone -b v5.1.2 --recursive https://github.com/espressif/esp-idf.git
fi

# -----------------------------
# Environment setup
# -----------------------------
echo "Configuring environment variables in $SHELL_RC ..."

if ! grep -q "ESP_IDF_DIR=" "$SHELL_RC"; then
  cat <<EOF >> "$SHELL_RC"

# === ESP Rust + ESP-IDF ===
export ESP_IDF_DIR="$ESP_IDF_DIR"
export IDF_PATH="\$ESP_IDF_DIR"
[ -f "\$HOME/export-esp.sh" ] && source "\$HOME/export-esp.sh"
[ -f "\$ESP_IDF_DIR/export.sh" ] && source "\$ESP_IDF_DIR/export.sh"
EOF
  echo "✔ Environment added"
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

command_exists ldproxy && ldproxy --version || echo "⚠ ldproxy not found"
command_exists idf.py && idf.py --version || echo "⚠ idf.py not found"

echo "=============================="
echo " Setup completed successfully "
echo "=============================="
echo "Workspace: $ESP_BASE"
echo "Restart terminal or run: source $SHELL_RC"
