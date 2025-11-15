# Created by Edwar Ricardo — https://github.com/El1Leon

# Troubleshooting (macOS 26 + Metal)

## GGUF Loading Errors
- **Symptom:** `gguf_reader: invalid magic` or `failed to load model`.
- **Fixes:**
  - Delete the suspect file from `~/models/<model>.gguf`.
  - Re-run the download with verification:
    ```bash
    hf download <repo> --include "<file>.gguf" --local-dir ~/models --resume-download
    ```
  - Compare the downloaded file size/hash with the Hugging Face listing before running `llama-cli` again.
  - Ensure the file extension remains `.gguf` and that no HTML/login page was saved instead during authentication issues.

## Metal Backend Not Detected
- Confirm you built with the Metal flags:
  ```bash
  cmake -DGGML_METAL=ON -DGGML_ACCELERATE=ON -B build -G Ninja
  ```
- Delete `./llama.cpp/build` if you previously configured without Metal; then rerun `./build.sh`.
- Verify you are on arm64 hardware: `uname -m` should output `arm64`.
- Reinstall Command Line Tools (`xcode-select --install`) after macOS updates so Metal headers remain available.

## Hugging Face Credential Errors
- Run `hf auth login` again and paste a fresh token from https://huggingface.co/settings/tokens.
- For SSO environments, supply `--token <PAT>` or set `HF_TOKEN` before invoking `hf download`.
- If the CLI claims the token is invalid, clear `~/.cache/huggingface/token` and login again.
- Ensure the token has at least "Read" scope for model downloads.

## macOS 26 CMake / SDK Edge Cases
- After system upgrades, re-run `sudo xcode-select --switch /Library/Developer/CommandLineTools` so CMake locates the proper SDK.
- Gatekeeper may quarantine new binaries—clear attributes via `xattr -d com.apple.quarantine ./llama.cpp/build/bin/llama-cli`.
- SIP may prevent execution from removable drives; keep the repo under your home directory or another trusted volume.
- If Ninja cannot find `metal` or `metallib`, upgrade Xcode/CLTs and reinstall Homebrew packages.

## Permissions Issues
- Ensure scripts are executable: `chmod +x install.sh build.sh run.sh`.
- Verify `~/models` is writable by your user; create it with `mkdir -p ~/models`.
- When using pyenv, confirm your shell profile loads `eval "$(pyenv init -)"` so `python` points to the managed interpreter.
- For Homebrew installs under `/opt/homebrew`, make sure your user owns the directories or run `brew doctor` to fix permissions.
