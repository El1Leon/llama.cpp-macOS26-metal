#!/usr/bin/env bash
# Apple Silicon Metal setup
# Maintained by El1Leon

set -euo pipefail

echo "[install] Checking Apple Silicon..."

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "Error: Apple Silicon Mac required."
    exit 1
fi

echo "[install] Checking Metal compiler..."

if ! xcrun --find metal >/dev/null 2>&1; then
    echo "Error: Metal compiler not found."
    echo "Check your Xcode and Metal toolchain installation."
    exit 1
fi

echo "[install] Checking Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required."
    echo "Visit https://brew.sh"
    exit 1
fi

echo "[install] Installing build dependencies..."

brew install git cmake ninja

echo "[install] Dependencies ready."
echo "[install] Next: ./build.sh"
