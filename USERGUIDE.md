# BurnLab User Guide

## System Requirements & Setup

### Hardware Prerequisites
*   **Storage**: 16GB USB 3.0 Drive (Minimum)
*   **RAM**: 4GB (Required), 8GB+ (Recommended)
*   **Processor**: 64-bit Intel/AMD CPU

### Phase 1: USB Creation (One-Time)
1.  Download **Ventoy** and install it to your USB drive.
2.  Download the **BunsenLabs Boron ISO**.
3.  Copy the ISO file directly onto the Ventoy partition.

### Phase 2: Deployment
BurnLab features a self-correcting installer that handles partitioning and software setup automatically.

1.  Boot your computer from the USB drive.
2.  Select **BunsenLabs** from the menu.
3.  Open a terminal and execute:
    ```bash
    git clone https://github.com/LoneMagma/BurnLab.git && cd BurnLab && sudo ./scripts/install.sh -y
    ```

**Note on Persistence**:
If this is a fresh USB, the installer will detect the lack of a persistence partition, create one, and prompt you to reboot. This is normal. Simply reboot, select the persistence option, and run the command again to finish installation.

---

## Operating Procedures

### The "Ask" Workflow
The core interaction loop of BurnLab is the `ask` command, which bridges offline documentation with generative AI.

**Syntax**: `ask "[query]"`

**Examples**:
*   `ask "Generate a Python script to parse JSON"`
*   `ask "Explain the difference between mutex and semaphore"`
*   `ask "How do I configure git user email?"`

### Knowledge Base Access
Access the offline encyclopedia and technical documentation directly.

**Command**: `kiwix-search "[term]"`
*   Searches all installed ZIM files (Wikipedia, StackOverflow, etc.).
*   Returns relevant article snippets and paths.

**Graphical Interface**:
To browse documentation like a website, launch the local server:
```bash
kiwix-serve ~/zims/*.zim
```
Then open `http://localhost:8080` in the browser.

### Project Management
Your development environment is persistent. All code should be stored in the home directory or the persistence partition.

*   **VS Code**: Pre-configured with Python and Web extensions.
*   **Git**: Pre-configured for local version control.

---

## Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **"Persistence not valid"** | Partition missing or unmounted | Re-run script with `-y` to force recreation. |
| **AI Response Slow** | Low RAM | Use the 1.5B model (default) instead of 7B. |
| **Download Failed** | No Internet | Connect to WiFi via system tray icon. |
| **Out of Space** | 16GB limit reached | Run `./scripts/tools/02_download_zims.sh "LITE"` to switch profiles. |
