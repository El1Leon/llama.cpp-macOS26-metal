# llama.cpp Apple Silicon Metal Toolkit

A lightweight toolkit for building, running, and verifying
[llama.cpp](https://github.com/ggml-org/llama.cpp) on
Apple Silicon Macs using Apple's Metal backend.

Originally developed for macOS 26 Tahoe.

## Features

- Apple Silicon architecture checks
- Metal compiler detection
- Automated dependency installation
- Metal-enabled llama.cpp compilation
- Apple Accelerate support
- Configurable GGUF model paths
- Configurable GPU layer offloading
- GPU device detection
- Optional model inference verification

## Requirements

- Apple Silicon Mac
- macOS with a supported Metal toolchain
- Xcode and the Metal toolchain
- Homebrew
- Internet connection for initial installation
- A compatible GGUF model for inference

NVIDIA CUDA is not required.

## Quick Start

Clone this toolkit:

```bash
git clone https://github.com/El1Leon/llama.cpp-macOS26-metal.git
cd llama.cpp-macOS26-metal
```

Install dependencies:

```bash
./install.sh
```

Build llama.cpp:

```bash
./build.sh
```

Verify the Metal environment:

```bash
./verify.sh
```

## Running a Model

Provide the path to an existing GGUF model:

```bash
MODEL_PATH="/path/to/model.gguf" ./run.sh
```

For a custom GPU layer count:

```bash
MODEL_PATH="/path/to/model.gguf" \
GPU_LAYERS=999 \
./run.sh
```

Models must be downloaded separately.

## Model Verification

To perform device detection and a model inference test:

```bash
MODEL_PATH="/path/to/model.gguf" ./verify.sh
```

The verification script confirms that a Metal device
is discoverable and that model inference completes.

It does not independently establish GPU layer placement.

## Tested Configuration

Successful local testing on October 30, 2026:

- Hardware: Apple M1 Max
- Reported macOS version: 27.2
- Architecture: ARM64
- Upstream llama.cpp commit: e0f142d5d
- Model: Qwen2.5-0.5B-Instruct Q4_K_M
- Metal backend: compiled and detected
- Model inference: successful
- Observed generation: 239.98 tokens/second

The performance result comes from one short inference run,
not a standardized benchmark.

Other Apple Silicon hardware and macOS versions
have not been independently verified with this revision.

## Project Files

- install.sh — Check environment and install build dependencies
- build.sh — Build official llama.cpp with Metal
- run.sh — Launch a GGUF model
- verify.sh — Verify devices and optionally test inference

The upstream llama.cpp source and generated build
are not distributed as part of this repository.

## Upstream Attribution

This toolkit builds upon the official
[llama.cpp](https://github.com/ggml-org/llama.cpp) project,
originally created by Georgi Gerganov and developed
by the ggml-org contributors.

The upstream developers are responsible for the
core inference engine, GGUF functionality, and
Metal backend.

This repository provides supplementary installation,
build, execution, and verification automation
for Apple Silicon.

Please consult the upstream repository for its
license and contribution information.

## License

See LICENSE for the license applicable to this toolkit.
Upstream llama.cpp retains its own license.
