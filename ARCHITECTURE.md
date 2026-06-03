# 🏛️ MANX OS Architecture Map

This document provides a high-level overview of the **MANX Engineering Workstation** configuration. It is designed to be a "living map" for understanding how the different layers of the system interact.

## 🚀 Core Philosophy

MANX OS is built on three pillars:

1.  **Statelessness**: The root filesystem is wiped on every boot to prevent system drift.
2.  **Modular Power**: Features like AI, VLSI tools, and custom branding are isolated into modular Nix files.
3.  **Unified Control**: The `manx` CLI serves as the single entry point for system maintenance.

---

## 📂 Directory Structure

### 🏗️ `/hosts` - Machine-Specific Entry Points

Each subdirectory here represents a unique physical machine.

- `common/`: Shared base configuration (Bootloader, Core settings).
- `manx/`: Primary engineering workstation (Desktop configuration).
- `laptop/`: Portable configuration (Power management, etc.).
- `variables.nix`: Local hardware/user variables (Untracked for privacy).

### 🧩 `/modules` - The Building Blocks

#### `modules/system/` (NixOS Level)

- `stateless.nix`: **The heart of the system.** Handles Btrfs rollback and Impermanence.
- `ai.nix`: Ollama (ROCm optimized) and Open-WebUI integration.
- `scripts.nix`: Contains the `manx` CLI and system-level utility scripts.
- `secrets.nix`: SOPS-Nix configuration for secure credential handling.
- `vivado.nix`: Containerized environment for AMD Xilinx tools.

#### `modules/home/` (Home Manager Level)

- `hyprland.nix`: Window manager configuration and custom terminal screensaver.
- `nixvim.nix`: Fully declarative Neovim environment tailored for engineering.
- `vlsi.nix`: Declarative toolchains for silicon design and hardware verification.

---

## 🛠️ Key Workflows

### 1. The Boot Sequence (Statelessness)

1.  **GRUB/Limine** loads the kernel.
2.  **initrd Phase**: `stateless.nix` executes a Btrfs script that:
    - Mounts the main partition.
    - Deletes the old `/root` subvolume.
    - Restores a blank snapshot to `/root`.
3.  **NixOS Activation**: Symlinks files from `/persist` back into the pristine root.

### 2. Secret Management

- Secrets are stored in `secrets/secrets.yaml` (encrypted via SOPS).
- Decryption happens at runtime using an `age` key stored in `/persist/var/lib/sops-nix/key.txt`.
- The `manx rebuild` command automatically stages/unstages these files to ensure they are never accidentally committed to Git in their raw state.

### 3. AI Orchestration

- **Backend**: Ollama runs as a system service with ROCm acceleration.
- **Frontend**: Open-WebUI provides a professional interface.
- **Key Sync**: `manx rebuild` reads tokens from `~/.config/manx/` and injects them into the service environment securely.

---

## 🔧 Maintenance Tooling (`manx`)

The `manx` command is the primary way to interact with the system. Key commands include:

- `manx rebuild`: Syncs config, formats code, validates flakes, and applies updates.
- `manx clean`: Deep cleans the Nix store and prunes old generations.
- `manx doctor`: Runs a borderless diagnostic suite to check system health.
- `manx aider`: Launches the AI-assisted coding environment.

---

## 🎨 Branding & UX

- **Theme**: "Silicon/VLSI" aesthetic.
- **Splash**: Custom Plymouth theme (`modules/system/plymouth.nix`).
- **Screensaver**: A custom Alacritty-based screensaver that displays ASCII art or images using `terminaltexteffects`.
