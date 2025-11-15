#!/bin/zsh
# Created by Edwar Ricardo — https://github.com/El1Leon
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
LLAMA_DIR="$SCRIPT_DIR/llama.cpp"
BUILD_DIR="$LLAMA_DIR/build"
REPO_URL="https://github.com/ggerganov/llama.cpp.git"

log() {
  printf '[build] %s\n' "$1"
}

if [ ! -d "$LLAMA_DIR/.git" ]; then
  log 'Cloning llama.cpp'
  rm -rf "$LLAMA_DIR"
  git clone "$REPO_URL" "$LLAMA_DIR"
else
  log 'Updating llama.cpp repository'
  git -C "$LLAMA_DIR" pull --ff-only
fi

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'Warning: this build is intended for macOS 26+. Detected %s.\n' "$(uname -s)" >&2
fi

if [ "$(uname -m)" != "arm64" ]; then
  printf 'Warning: Metal builds expect arm64 hardware. Detected %s.\n' "$(uname -m)" >&2
fi

log 'Configuring CMake with Metal + Accelerate'
cmake -S "$LLAMA_DIR" -B "$BUILD_DIR" -G Ninja \
  -DGGML_METAL=ON \
  -DGGML_ACCELERATE=ON

log 'Building via Ninja'
ninja -C "$BUILD_DIR"

log "Build complete. Binary at $BUILD_DIR/bin/llama-cli"
