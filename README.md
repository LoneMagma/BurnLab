<div align="center">

<!--
BurnLab README (enhanced)
Notes:
- GitHub renders HTML in README; Obsidian will too, but if you want a pure-Markdown variant,
  I can generate a "no-HTML" README as well.
-->

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=800&size=44&pause=900&color=FF6B00&center=true&vCenter=true&width=980&lines=BurnLab;Sovereign+AI+Dev+Environment;Air%E2%80%91gapped.+Zero%E2%80%91trace.+Portable." alt="BurnLab Typing Hero" />

<br/>

<strong>BurnLab turns a USB drive into a self-contained AI dev lab.</strong><br/>
<span>Offline LLMs • Offline docs • Pro tooling • Runs on x86_64 without touching the host OS</span>

<br/><br/>

<a href="https://github.com/LoneMagma/BurnLab">
  <img alt="Repo" src="https://img.shields.io/badge/repo-LoneMagma%2FBurnLab-111827?style=for-the-badge&labelColor=000000"/>
</a>
<a href="https://github.com/LoneMagma/BurnLab/stargazers">
  <img alt="Stars" src="https://img.shields.io/github/stars/LoneMagma/BurnLab?style=for-the-badge&labelColor=000000"/>
</a>
<a href="https://github.com/LoneMagma/BurnLab/issues">
  <img alt="Issues" src="https://img.shields.io/github/issues/LoneMagma/BurnLab?style=for-the-badge&labelColor=000000"/>
</a>
<a href="LICENSE">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-2563eb?style=for-the-badge&labelColor=000000"/>
</a>
<a href="https://www.bunsenlabs.org/">
  <img alt="Platform" src="https://img.shields.io/badge/platform-BunsenLabs%20%7C%20Debian-9ca3af?style=for-the-badge&labelColor=000000"/>
</a>

<br/><br/>

<p>
  <a href="#core-capabilities">Core</a> •
  <a href="#quick-start">Quick start</a> •
  <a href="#interaction-guide">Commands</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#troubleshooting">Troubleshooting</a> •
  <a href="#documentation">Docs</a>
</p>

</div>

---

# BurnLab
> **The Sovereign AI Development Environment**

BurnLab transforms a standard USB drive into an **air-gapped, AI-powered software development laboratory**.  
It provides a complete verified environment with **local LLMs**, **offline documentation**, and **professional tooling** — designed to run on any **x86_64** hardware **without touching the host OS**.

> **Zero‑Trace promise:** runs from RAM + USB. No data is written to the host machine.

---

## Core capabilities

| Pillar | What you get | Why it matters |
|---|---|---|
| **Local Intelligence** | Ollama runtime + **Qwen2.5‑Coder** (1.5B / 7B) | Offline codegen + debugging |
| **Universal Reference** | **15GB+** offline knowledge: Wikipedia, Stack Overflow, MDN, Arch Wiki | No internet needed mid‑flow |
| **Professional Tooling** | VS Code, Python **3.11+** stack, Git, build essentials | Real work, not demos |
| **Adaptive Storage** | Smart compression + dynamic partitioning | Fits on **16GB** (32GB+ nicer) |
| **Zero‑Trace** | RAM + USB execution; no host writes | Portable + safe |

<details>
<summary><b>When should I use BurnLab?</b></summary>

- You want a **portable lab** you can boot anywhere (friends PC, lab PC, old laptop).
- You want **offline coding + docs** on unreliable networks.
- You want a dev box that leaves **no footprint** on the host.

</details>

---

## Quick start

> The entire environment can be bootstrapped with a single command.

### 1) Requirements

| Item | Minimum | Recommended |
|---|---:|---:|
| USB Drive | **16GB** | **32GB+** |
| RAM | **4GB** | **8GB+** |
| CPU | **x86_64 Intel/AMD** | x86_64 |
| Network (install only) | Wi‑Fi / Ethernet | Stable connection |

### 2) USB creation (one‑time)

1. Install **Ventoy** on your USB.
2. Download the **BunsenLabs Boron ISO**.
3. Copy the ISO onto the Ventoy partition.

(That’s the “carrier OS” — BurnLab installs itself inside it.)

### 3) Install / deploy

Boot into **BunsenLabs Boron (Live USB)** → connect to Wi‑Fi → open a terminal → run:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/LoneMagma/BurnLab/main/scripts/bootstrap.sh)
```

> [!NOTE]
> **What this does (high level):**
> 1) Ensures `git` exists  
> 2) Clones or pulls the repo into `~/BurnLab`  
> 3) Makes scripts executable  
> 4) Launches the installer (`sudo ./scripts/install.sh -y`)  

> [!IMPORTANT]
> **You will reboot once.** After reboot, run the command again to finish AI/tools setup (this is normal).

---

## Interaction guide

BurnLab replaces complex configuration with intuitive aliases.

| Task | Command | What it does |
|---|---|---|
| **Ask AI** | `ask "How do I reverse a list via slicing?"` | Queries the local LLM with doc context |
| **Search docs** | `kiwix-search "python decorators"` | Full‑text search across offline knowledge base |
| **Browse docs UI** | `kiwix-serve ~/zims/*.zim` | Launch local docs server (`http://localhost:8080`) |
| **Workspace** | `code ~/projects/my-app` | Opens your portable VS Code workspace |
| **System status** | `sys-status` | Memory, storage, model status |

<details>
<summary><b>Pro tip: keep projects in the persistent area</b></summary>

Store code in your home directory / persistence partition so it survives reboots:
- `~/projects/<your-project>`
- Keep exports in `~/exports/`

</details>

---

## Architecture

BurnLab uses a layered design to stay fast on limited hardware:

```text
┌─────────────────────────────────────────────────────┐
│  Base Layer: BunsenLabs (Debian Stable)             │
│  - hardware support, stability                      │
├─────────────────────────────────────────────────────┤
│  Persistence Layer: Btrfs + zstd compression        │
│  - saves space, keeps dev state                     │
├─────────────────────────────────────────────────────┤
│  Knowledge Layer: Kiwix ZIM archives                │
│  - dense offline docs (Wiki, SO, MDN, Arch)         │
├─────────────────────────────────────────────────────┤
│  Intelligence Layer: Ollama + quantized LLMs (CPU)  │
│  - offline code + reasoning                         │
└─────────────────────────────────────────────────────┘
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| **“Persistence not valid”** | persistence file missing/unmounted | Re-run bootstrap; if needed run installer with `-y` to recreate |
| **AI is slow** | low RAM / bigger model | Use the **1.5B** model instead of **7B** |
| **Download failed** | no internet during install phase | Connect to Wi‑Fi via system tray, then re-run |
| **Out of space (16GB)** | knowledge base too large | Switch to the **LITE** profile when downloading docs |

<details>
<summary><b>LITE profile (space saver)</b></summary>

If you’re on a 16GB drive and running out of space, use the lighter docs profile:

```bash
./scripts/tools/02_download_zims.sh "LITE"
```

</details>

---

## Documentation

- **User Guide:** `USERGUIDE.md` (boot strategy, procedures, advanced config)
- **License:** `LICENSE` (MIT)

---

## License

This project is open-source under the **MIT License**.

---

<div align="center">
  built by <a href="https://github.com/LoneMagma">LoneMagma</a> • sovereign tools for sovereign work.
</div>
