# Created by Edwar Ricardo — https://github.com/El1Leon

# HuggingFace + llama.cpp on macOS 26 (Metal)

This repository explains the exact steps for setting up Apple Silicon Macs (macOS 26+) to run [`llama.cpp`](https://github.com/ggerganov/llama.cpp) with Metal acceleration, download GGUF checkpoints from Hugging Face, and launch `llama-cli` safely using generic, public-ready instructions.

## Overview
1. Install the system dependencies (Homebrew, Command Line Tools, pyenv, Python 3.12).
2. Configure the Hugging Face CLI (`huggingface_hub` 0.36.0) and authenticate with a token.
3. Download `llama.cpp`, configure it with Metal flags, and build via Ninja.
4. Fetch GGUF models into `~/models/<model-name>.gguf` using `hf download`.
5. Run models with `./build/bin/llama-cli -m ~/models/<model>.gguf --n-gpu-layers 100 -p "Hello"`.
6. Reference the troubleshooting guide for GGUF, Metal, token, and macOS issues.

## macOS 26+ Compatibility Notes
- Requires Apple Silicon hardware (arm64) with Metal support enabled.
- Ensure the latest Xcode Command Line Tools are installed (`xcode-select --install`).
- SIP and Gatekeeper can quarantine binaries copied from external drives—keep the repo under `~/Projects` or another trusted location.

## Install Dependencies
Run `./install.sh` to automate everything or follow the steps manually:
1. Install/upgrade Homebrew formulas:
   ```bash
   brew update
   brew install cmake ninja git jq pyenv pipx
   ```
2. Initialize pyenv in your shell (`eval "$(pyenv init -)"`).
3. Install Python 3.12 and make it local to this project:
   ```bash
   pyenv install 3.12.0
   pyenv local 3.12.0
   python --version  # confirm 3.12.x
   ```
4. Ensure pipx is available: `pipx ensurepath` then open a new terminal.
5. Install the Hugging Face CLI (v0.36.0):
   ```bash
   pipx install "huggingface_hub[cli]==0.36.0" --force
   hf --version  # should show 0.36.0
   ```

## Generate & Use a Hugging Face Token
1. Go to https://huggingface.co/settings/tokens and create a read token.
2. Run `hf auth login` and paste the token when prompted (or use the browser/device flow).
3. Tokens are stored in your user cache, never in this repository.

## Download llama.cpp
Clone the upstream project inside this folder (handled automatically by `./build.sh`):
```
https://github.com/ggerganov/llama.cpp
```
This repository is only a wrapper; it expects the sources under `./llama.cpp`.

## Build llama.cpp with Metal
Use `./build.sh` or run the commands directly:
```bash
cmake -S ./llama.cpp -B ./llama.cpp/build -G Ninja \
  -DGGML_METAL=ON \
  -DGGML_ACCELERATE=ON
ninja -C ./llama.cpp/build
```
These flags ensure Metal kernels and Accelerate BLAS are enabled for Apple Silicon.

## Download GGUF Models (hf download 0.36.0)
Always store models inside `~/models/<model-name>.gguf`:
```bash
mkdir -p ~/models
hf download <repo> --include "<file>.gguf" --local-dir ~/models
```
Examples:
```bash
hf download meta-llama/Meta-Llama-3.1-8B-Instruct-GGUF \
  --include "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" \
  --local-dir ~/models
hf download TheBloke/Qwen2-7B-Instruct-GGUF \
  --include "*Q4_K_M.gguf" \
  --local-dir ~/models
```
Add `--resume-download` to recover interrupted transfers and set `HF_HUB_ENABLE_HF_TRANSFER=1` for faster downloads.

## Run GGUF Models with llama-cli
Launch `./run.sh` or call the binary manually:
```bash
./llama.cpp/build/bin/llama-cli \
  -m ~/models/<model>.gguf \
  --n-gpu-layers 100 \
  -p "Hello"
```
Pass additional flags (`--ctx-size`, `--batch-size`, `--temperature`, etc.) as needed.

## Common Errors & Fixes
- **GGUF “invalid magic”** – Delete the file from `~/models`, rerun `hf download ... --resume-download`, and verify the file size/hash from the Hugging Face repo.
- **Metal backend not detected** – Ensure you built with `-DGGML_METAL=ON -DGGML_ACCELERATE=ON`, delete `./llama.cpp/build`, rerun `./build.sh`, and confirm you’re on arm64 macOS 26.
- **Hugging Face token issues** – Re-run `hf auth login`, regenerate tokens from your account page, and confirm `HF_TOKEN` is not empty in CI environments.
- **macOS 26 SDK problems** – Reinstall Command Line Tools after OS updates, clear `xcode-select --switch /Library/Developer/CommandLineTools`, and make sure Ninja/CMake see the new SDK path.

## Troubleshooting
See [`troubleshooting.md`](./troubleshooting.md) for expanded instructions on:
- GGUF loading failures
- Metal backend detection
- HF credential handling
- macOS 26 CMake/SDK quirks

## Next Steps
1. `./install.sh`
2. `./build.sh`
3. `hf download <repo> --include "<file>" --local-dir ~/models`
4. `./run.sh "Hello from macOS 26"`
