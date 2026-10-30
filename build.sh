#!/usr/bin/env bash
# Build upstream llama.cpp for Apple Silicon with Metal.
# Upstream: https://github.com/ggml-org/llama.cpp

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_DIR="$SCRIPT_DIR/llama.cpp"
BUILD_DIR="$LLAMA_DIR/build"

REPO_URL="https://github.com/ggml-org/llama.cpp.git"
LLAMA_REF="${LLAMA_REF:-e0f142d5d}"

if [[ "$(uname -s)" != "Darwin" ||
      "$(uname -m)" != "arm64" ]]; then
    echo "[build] Apple Silicon Mac required." >&2
    exit 1
fi

for tool in git cmake ninja; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[build] Missing dependency: $tool" >&2
        exit 1
    fi
done

if [[ ! -d "$LLAMA_DIR/.git" ]]; then
    echo "[build] Cloning official llama.cpp..."
    git clone "$REPO_URL" "$LLAMA_DIR"
fi

echo "[build] Checking upstream version..."

git -C "$LLAMA_DIR" remote set-url origin "$REPO_URL"

if ! git -C "$LLAMA_DIR" cat-file -e "${LLAMA_REF}^{commit}" 2>/dev/null; then
    echo "[build] Fetching upstream commits..."
    git -C "$LLAMA_DIR" fetch origin
fi

if [[ -n "$(git -C "$LLAMA_DIR" status --porcelain)" ]]; then
    echo "[build] Upstream checkout has local changes." >&2
    echo "[build] Preserve those changes before switching commits." >&2
    exit 1
fi

git -C "$LLAMA_DIR" checkout --detach "$LLAMA_REF"

echo "[build] Configuring Metal + Accelerate..."

cmake -S "$LLAMA_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DGGML_ACCELERATE=ON

echo "[build] Compiling..."
cmake --build "$BUILD_DIR" --parallel 4

echo "[build] Complete."
echo "[build] Binary: $BUILD_DIR/bin/llama-cli"
