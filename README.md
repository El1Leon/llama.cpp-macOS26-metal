<!--
  Project by Edwar Ricardo
  GitHub: https://github.com/El1Leon
-->

# llama.cpp Metal on macOS 26+
### Run local LLaMA models on Apple Silicon (Metal) with Hugging Face support

This guide explains exactly how to reproduce the working setup for:
- macOS 26 (Tahoe)
- Apple Silicon (M1/M2/M3/M4/M5)
- llama.cpp **Metal acceleration enabled**
- Hugging Face HF CLI (v0.36.0) working properly
- Python (3.12.x recommended)
- GGUF model loading and execution through `llama-cli`

The purpose of this repo is to give users a **fully working, verified setup** that avoids all the hidden macOS 26 pitfalls.

---

## 📦 1. Requirements

Before starting, make sure you have:

| Tool | Required Version |
|------|------------------|
| macOS | **26+ (Tahoe)** |
| Xcode | Latest (for Metal + clang 17) |
| Python | **3.12.x** |
| Homebrew | Recommended |
| Ninja | Required by llama.cpp |
| CMake | Required by llama.cpp |
| HuggingFace Hub CLI | **0.36.0** (stable + compatible) |

Install base dependencies (skip if you plan to run `./install.sh`, which already does this):

```zsh
brew install cmake ninja python@3.12 jq
```

> **Shortcut:** running `./install.sh` handles the Homebrew packages, installs `pyenv` 3.12.0, and sets up `pipx` + Hugging Face CLI automatically. Use it whenever possible to stay aligned with these docs.

---

## 📥 2. Download llama.cpp (Official)

This repo uses the official upstream llama.cpp:

https://github.com/ggerganov/llama.cpp

You can clone it manually:

```zsh
git clone https://github.com/ggerganov/llama.cpp.git
```

Or rely on this repo’s script:

```zsh
./build.sh
```

The script will automatically:
- clone llama.cpp if it isn’t present
- apply CMake Metal flags:
  - `-DGGML_METAL=ON`
  - `-DGGML_ACCELERATE=ON`
- build binaries into:

```
llama.cpp/build/bin/
```

---

## ⚙️ 3. Install Hugging Face CLI (Correct Version)

macOS 26 breaks newer HuggingFace CLI releases, so install **v0.36.0** with `pipx` (recommended) or pip:

```zsh
pipx ensurepath
pipx install "huggingface_hub[cli]==0.36.0" --force
```

Then authenticate:

```zsh
hf auth login
```

You *do not* need to store your token as a Git credential — choose **“n”** when asked. If you prefer not to use pipx, `pip install huggingface_hub==0.36.0` works as well, but you’ll need to manage PATH yourself.

---

## 📥 4. Download a Small GGUF Model

For a fast first run, use **Qwen2.5 0.5B Instruct**. It is much smaller than an 8B model and is a better default for confirming that Metal, `hf`, and `llama.cpp` all work.

```zsh
mkdir -p "$HOME/models/qwen-small"
hf download bartowski/Qwen2.5-0.5B-Instruct-GGUF --include Qwen2.5-0.5B-Instruct-Q4_K_M.gguf --local-dir "$HOME/models/qwen-small"
```

> Keep the `hf download` command on one line when pasting it into zsh. If you split the line after `--local-dir`, the shell will treat the model directory as a separate command.

The file should appear at:

```
~/models/qwen-small/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf
```

### Optional: larger model

After the small model works, you can try a larger 8B model for better responses:

```zsh
mkdir -p "$HOME/models/llama-8b"
hf download bartowski/Meta-Llama-3.1-8B-Instruct-GGUF \
  --include "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" \
  --local-dir "$HOME/models/llama-8b"
```

You can list available files via the Hugging Face API:

```zsh
curl -s https://huggingface.co/api/models/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF | jq '.siblings[].rfilename'
```

---

## 🚀 5. Run llama.cpp with Metal

From the repo root:

```zsh
MODEL_DIR="$HOME/models/qwen-small" ./run.sh Hello
```

If everything is correct, you will see Metal initialization:

```
ggml_metal_device_init: GPU name: Apple M1 Max
ggml_metal_device_init: simdgroup reduction = true
...
load_tensors: offloaded ... layers to GPU
```

Then the model will load and print a response.

---

## 🛠 Included Scripts in This Repo

| Script | Purpose |
|--------|---------|
| **install.sh** | Installs Python + HF CLI + Brew deps |
| **build.sh** | Clones llama.cpp and builds Metal binaries |
| **run.sh** | Runs a GGUF model with Metal-accelerated llama-cli |
| **troubleshooting.md** | Fixes every known macOS 26 error |

Run them in order:

```zsh
./install.sh
./build.sh
mkdir -p "$HOME/models/qwen-small"
hf download bartowski/Qwen2.5-0.5B-Instruct-GGUF --include Qwen2.5-0.5B-Instruct-Q4_K_M.gguf --local-dir "$HOME/models/qwen-small"
MODEL_DIR="$HOME/models/qwen-small" ./run.sh Hello
```

`run.sh` uses the first `.gguf` file it finds under `MODEL_DIR`, or a specific `MODEL_PATH` if you provide one:

```zsh
MODEL_PATH=/path/to/model.gguf ./run.sh "Hello!"
```

You can also override runtime defaults:

```zsh
GPU_LAYERS=999 N_PREDICT=256 ./run.sh "Explain Metal acceleration briefly."
```

---

## 🧩 Troubleshooting

See: `troubleshooting.md`

Includes fixes for:

- HF CLI not found  
- GGUF not recognized  
- Metal backend not detected  
- “tensor API disabled” warnings  
- macOS 26 linker quirks  
- Python/pyenv conflicts

---

## 📚 Summary

You now have a fully working:

- macOS 26 + Metal llama.cpp setup  
- HuggingFace GGUF downloader  
- Python 3.12-compatible environment  
- Reliable build + run scripts  

This repo exists so you don’t have to repeat hours of debugging — everything here has been tested end-to-end.

Enjoy running LLaMA locally on Metal! 🚀🔥
