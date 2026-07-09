#!/bin/zsh
# Created by: Edwar Ricardo — https://github.com/El1Leon
set -euo pipefail

DEFAULT_PROMPT="Hello! Respond with one short sentence."
PROMPT="${*:-$DEFAULT_PROMPT}"
GPU_LAYERS="${GPU_LAYERS:-100}"
N_PREDICT="${N_PREDICT:-128}"

log() {
  printf '[run] %s\n' "$1"
}

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
LLAMA_BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-cli"

if [ ! -x "$LLAMA_BIN" ]; then
  printf 'Error: llama-cli not found at %s\n' "$LLAMA_BIN" >&2
  exit 1
fi

MODEL_REPO="bartowski/Qwen2.5-0.5B-Instruct-GGUF"
MODEL_NAME="Qwen2.5-0.5B-Instruct-Q4_K_M.gguf"
MODEL_DIR="${MODEL_DIR:-$HOME/models}"
MODEL_PATH="${MODEL_PATH:-$MODEL_DIR/$MODEL_NAME}"

if [ ! -f "$MODEL_PATH" ] && [ -d "$MODEL_DIR" ]; then
  gguf_files=("$MODEL_DIR"/**/*.gguf(N.))
  if [ ${#gguf_files[@]} -gt 0 ]; then
    MODEL_PATH="${gguf_files[1]}"
  fi
fi

if [ ! -f "$MODEL_PATH" ]; then
  cat >&2 <<EOF
Error: no GGUF model found.

Looked for:
  $MODEL_PATH

Download the default model with:
  mkdir -p "$MODEL_DIR"
  hf download "$MODEL_REPO" \\
    --include "$MODEL_NAME" \\
    --local-dir "$MODEL_DIR"

Or run with a specific model:
  MODEL_PATH=/path/to/model.gguf $0 "Hello!"
EOF
  exit 1
fi

log "Running llama.cpp with model: $MODEL_PATH"
log "Prompt: $PROMPT"

"$LLAMA_BIN" \
  -m "$MODEL_PATH" \
  --n-gpu-layers "$GPU_LAYERS" \
  --predict "$N_PREDICT" \
  -p "$PROMPT"
