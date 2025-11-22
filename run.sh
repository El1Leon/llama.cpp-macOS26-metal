#!/bin/zsh
# Created by: Edwar Ricardo — https://github.com/El1Leon
set -euo pipefail

if [ $# -eq 0 ]; then
  printf 'Usage: %s "prompt text"\n' "$0" >&2
  exit 1
fi

PROMPT="$*"

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
LLAMA_BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-cli"

if [ ! -x "$LLAMA_BIN" ]; then
  printf 'Error: llama-cli not found at %s\n' "$LLAMA_BIN" >&2
  exit 1
fi

MODEL_NAME="Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
MODEL_PATH="$HOME/models/$MODEL_NAME"

if [ ! -f "$MODEL_PATH" ]; then
  printf 'Error: Model not found: %s\n' "$MODEL_PATH" >&2
  exit 1
fi

printf '[run] Running llama.cpp with model: %s\n' "$MODEL_PATH"

"$LLAMA_BIN" \
  -m "$MODEL_PATH" \
  --n-gpu-layers 100 \
  -p "$PROMPT"