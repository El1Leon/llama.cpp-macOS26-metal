#!/bin/zsh
# Created by Edwar Ricardo — https://github.com/El1Leon
set -euo pipefail

if [ $# -eq 0 ]; then
  printf 'Usage: %s "prompt text"\n' "$0" >&2
  exit 1
fi

PROMPT="$*"
SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
LLAMA_BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-cli"

if [ ! -x "$LLAMA_BIN" ]; then
  printf 'llama-cli not found at %s. Run ./build.sh first.\n' "$LLAMA_BIN" >&2
  exit 1
fi

read "?Enter the GGUF model filename (without path, stored in ~/models): " MODEL_NAME
MODEL_NAME="${MODEL_NAME##*/}"
MODEL_PATH="$HOME/models/$MODEL_NAME"

if [ ! -f "$MODEL_PATH" ]; then
  printf 'Model file %s does not exist. Download it into ~/models.\n' "$MODEL_PATH" >&2
  exit 1
fi

log() {
  printf '[run] %s\n' "$1"
}

log "Running llama-cli with $MODEL_PATH"
"$LLAMA_BIN" \
  -m "$MODEL_PATH" \
  --n-gpu-layers 100 \
  -p "$PROMPT"
