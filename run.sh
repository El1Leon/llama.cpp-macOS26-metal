#!/usr/bin/env bash
# Run a GGUF model using upstream llama.cpp.
# Upstream: https://github.com/ggml-org/llama.cpp

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$SCRIPT_DIR/llama.cpp/build/bin/llama-cli"

MODEL_PATH="${MODEL_PATH:-}"
GPU_LAYERS="${GPU_LAYERS:-999}"

if [[ ! -x "$BIN" ]]; then
    echo "[run] llama-cli not found. Run ./build.sh first." >&2
    exit 1
fi

if [[ -z "$MODEL_PATH" ]]; then
    echo "[run] Set MODEL_PATH to your GGUF file." >&2
    echo "Example:" >&2
    echo 'MODEL_PATH="$HOME/models/model.gguf" ./run.sh' >&2
    exit 1
fi

if [[ ! -f "$MODEL_PATH" ]]; then
    echo "[run] Model not found: $MODEL_PATH" >&2
    exit 1
fi

echo "[run] Model: $MODEL_PATH"
echo "[run] GPU layers requested: $GPU_LAYERS"

exec "$BIN" \
    -m "$MODEL_PATH" \
    -ngl "$GPU_LAYERS" \
    "$@"
