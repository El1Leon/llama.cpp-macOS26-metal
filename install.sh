#!/bin/zsh
# Created by Edwar Ricardo — https://github.com/El1Leon
set -euo pipefail

log() {
  printf '[install] %s\n' "$1"
}

BREW_PACKAGES=(cmake ninja git jq pyenv pipx)
PYTHON_VERSION="3.12.0"

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is required. Install it from https://brew.sh first.\n' >&2
  exit 1
fi

log "Installing Homebrew packages: ${BREW_PACKAGES[*]}"
brew update >/dev/null
brew install ${BREW_PACKAGES[*]} >/dev/null || true

if ! command -v pyenv >/dev/null 2>&1; then
  printf 'pyenv was not installed correctly. Check Homebrew output.\n' >&2
  exit 1
fi

eval "$(pyenv init -)"

if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
  log "Installing Python $PYTHON_VERSION via pyenv"
  pyenv install "$PYTHON_VERSION"
fi

log "Setting local Python to $PYTHON_VERSION"
pyenv local "$PYTHON_VERSION"
python -m pip install --upgrade pip >/dev/null

if ! command -v pipx >/dev/null 2>&1; then
  log 'pipx not detected; installing via pip'
  python -m pip install --user --upgrade pipx
fi

python -m pipx ensurepath >/dev/null
export PATH="$HOME/.local/bin:$PATH"

log 'Installing huggingface_hub[cli]==0.36.0 via pipx'
pipx install "huggingface_hub[cli]==0.36.0" --force >/dev/null

if ! command -v hf >/dev/null 2>&1; then
  printf 'hf CLI not found on PATH after installation. Check pipx configuration.\n' >&2
  exit 1
fi

log 'hf CLI detected:'
hf --version

log 'Installation complete.'
