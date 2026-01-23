# BurnLab
> **The Sovereign AI Development Environment**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-BunsenLabs%20%7C%20Debian-lightgrey.svg)](https://www.bunsenlabs.org/)
[![Status](https://img.shields.io/badge/status-stable-success.svg)]()
![Size](https://img.shields.io/badge/size-16GB%2B-orange.svg)

BurnLab transforms a standard USB drive into an air-gapped, AI-powered software development laboratory. It provides a complete verified environment with local LLMs, offline documentation, and professional tooling, designed to run on any x86_64 hardware without touching the host OS.

## Core Capabilities

*   **Local Intelligence**: Integrated Ollama runtime with Qwen2.5-Coder (1.5B/7B) for offline code generation and debugging.
*   **Universal Reference**: 15GB+ of offline knowledge including Wikipedia, Stack Overflow, MDN, and Arch Wiki.
*   **Professional Tooling**: VS Code, Python 3.11+ Scientific Stack, Git, and build essentials.
*   **Adaptive Storage**: Smart compression and dynamic partitioning allow full functionality on 16GB drives.
*   **Zero-Trace**: Runs entirely from RAM and USB. No data is written to the host computer.

---

## Quick Start

The entire environment can be bootstrapped with a single command.

### 1. Requirements
*   **USB Drive**: 16GB (Minimum) or 32GB+ (Recommended).
*   **Host System**: Any PC with 4GB+ RAM.

### 2. Analysis & Installation
Boot into **BunsenLabs Boron** (Live USB), connect to WiFi, open a terminal, and run:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/LoneMagma/BurnLab/main/scripts/bootstrap.sh)
```

> [!NOTE]
> **What this does:**
> 1.  Installs `git` automatically.
> 2.  Downloads the BurnLab repository.
> 3.  **Configures Persistence**: If your USB is full (Ventoy default), it safely creates a persistence file and configures Ventoy to use it.
> 4.  **Reboot Prompt**: You will be asked to reboot.
> 5.  **Resume**: After rebooting (selecting "Persistence" or the ISO again if using Ventoy), run the command again to finish installing the AI and Tools.

---

## Interaction Guide

BurnLab replaces complex configurations with intuitive aliases.

| Task | Command | Description |
| :--- | :--- | :--- |
| **Ask AI** | `ask "How do I reverse a list via slicing?"` | Queries local LLM with context from offline docs. |
| **Search Docs** | `kiwix-search "python decorators"` | Searches across all installed offline wikis. |
| **Workspace** | `code ~/projects/my-app` | Launches portable VS Code environment. |
| **System Info** | `sys-status` | Displays memory, storage, and model status. |

## Architecture

BurnLab uses a layered architecture to maximize efficiency on limited hardware:

1.  **Base Layer**: BunsenLabs (Debian Stable) for rock-solid hardware support.
2.  **Persistence Layer**: Btrfs with `zstd:15` transparent compression (saves ~40% space).
3.  **Knowledge Layer**: Kiwix ZIM archives for high-density documentation storage.
4.  **Intelligence Layer**: Quantized LLMs running on CPU for universal compatibility.

## Documentation

For a detailed walkthrough of the installation process, boot strategy, and advanced configurations, please refer to the [User Guide](USERGUIDE.md).

## License

This project is open-source under the [MIT License](LICENSE).
