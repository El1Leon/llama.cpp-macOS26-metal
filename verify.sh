#!/usr/bin/env bash
# Apple Silicon llama.cpp environment verification

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/llama.cpp/build"
BIN="$BUILD_DIR/bin/llama-cli"

echo "=== Apple Silicon Metal Verification ==="

if [[ "$(uname -s)" != "Darwin" ||
      "$(uname -m)" != "arm64" ]]; then
    echo "[FAIL] Apple Silicon Mac required."
    exit 1
fi

echo "[OK] Apple Silicon detected"
sw_vers -productVersion

if ! xcrun --find metal >/dev/null 2>&1; then
    echo "[FAIL] Metal compiler not found."
    exit 1
fi

echo "[OK] Metal compiler available"

if [[ ! -x "$BIN" ]]; then
    echo "[FAIL] llama-cli missing. Run ./build.sh."
    exit 1
fi

echo "[OK] llama-cli executable found"

CACHE="$BUILD_DIR/CMakeCache.txt"

if [[ -f "$CACHE" ]]; then
    if grep -Eq '^GGML_METAL:BOOL=ON$' "$CACHE"; then
        echo "[OK] Metal enabled in CMake"
    else
        echo "[FAIL] Metal not enabled in CMake"
        exit 1
    fi
else
    echo "[WARN] CMake cache not found"
fi

echo
echo "=== Available Compute Devices ==="

DEVICES="$("$BIN" --list-devices 2>&1)"
printf '%s\n' "$DEVICES"

if ! grep -Eq 'MTL[0-9]+: Apple' <<< "$DEVICES"; then
    echo "[FAIL] Apple Metal GPU not detected."
    exit 1
fi

echo
echo "[PASS] Apple Metal GPU detected"

if [[ -n "${MODEL_PATH:-}" ]]; then
    echo
    echo "=== Model Inference Test ==="

    if [[ ! -f "$MODEL_PATH" ]]; then
        echo "[FAIL] Model not found: $MODEL_PATH"
        exit 1
    fi

    "$SCRIPT_DIR/llama.cpp/build/bin/llama-completion" \
        -m "$MODEL_PATH" \
        -ngl "${GPU_LAYERS:-999}" \
        -p 'Hello!' \
        -n 32 \
        -no-cnv

    echo "[PASS] Model inference completed"
fi
