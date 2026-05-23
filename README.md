# 🛰️ MANX OS: Engineering-Grade Workstation
### A Declarative Ecosystem for VLSI, Deep Learning, and Hardware Design

[![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Kernel](https://img.shields.io/badge/Kernel-CachyOS_v3-ea00d9.svg?style=flat-square&logo=linux&logoColor=white)](https://github.com/CachyOS)
[![Storage](https://img.shields.io/badge/Storage-Btrfs_LUKS-00ff00.svg?style=flat-square&logo=nixos&logoColor=white)](https://btrfs.readthedocs.io/en/latest/index.html)
[![WM](https://img.shields.io/badge/WM-Hyprland-ffb59e.svg?style=flat-square&logo=hyprland&logoColor=white)](https://hyprland.org)
[![Editor](https://img.shields.io/badge/Editor-Nixvim-green.svg?style=flat-square&logo=neovim&logoColor=white)](https://github.com/nix-community/nixvim)

---

<div align="center">
  <img src="assets/screenshots/sddm.png" alt="MANX OS SDDM Theme" width="100%">
  <br/>
  <i>Modular authentication interface featuring native Verilog syntax highlighting.</i>
</div>

---

## 🔬 Core Mission
This workstation is a specialized NixOS distribution designed for **Microelectronics Engineers** and **Deep Learning Researchers**. It bridges the gap between the cutting-edge Linux ecosystem and the historically rigid world of proprietary EDA (Electronic Design Automation) tools.

The environment is built on **Stateless Btrfs Architecture**, meaning the system resets to a pristine state on every boot, ensuring absolute stability and preventing "configuration drift" over years of heavy engineering work.

---

## 🏗️ System Architecture & Reliability

### 🛡️ Stateless Integrity (Impermanence)
*   **Root Rollback:** The root partition (`/`) is wiped and restored from a blank Btrfs snapshot during the `initrd` phase of every boot.
*   **Persistent State:** Only critical data (SSH keys, NetworkManager profiles, and the Nix Config) is preserved in `/persist` via bind-mounts.
*   **Time-Machine Backups:** The `/home` directory is protected by **Snapper**, providing automated hourly snapshots for accidental data recovery.

### ⚡ Performance Tuning
*   **CachyOS Kernel:** Optimized for the `x86_64-v3` microarchitecture to maximize throughput in simulation and training workloads.
*   **Latency Management:** Leverages the **sched-ext** framework with the `scx_lavd` scheduler for a zero-lag desktop experience even under 100% CPU load.
*   **GPU Acceleration:** Integrated **ROCm** stack for AMD hardware, enabling native HIP and OpenCL support for Deep Learning frameworks and GPU-accelerated simulators.

---

## 🛠️ The Engineering Stack

### 🟦 VLSI & Digital Verification
A production-grade toolchain for RTL design and functional verification:
*   **Simulation:** `Verilator` (High-performance C++ cycle-accurate), `Icarus Verilog`, `NVC` (VHDL).
*   **Formal Verification:** `SBY` (SymbiYosys) for bounded model checking.
*   **Physical Design:** `Magic-VLSI` and `KLayout` for GDSII layout and DRC.
*   **Python-Based DV:** Native `cocotb` integration for modern coroutine-based cosimulation.

### 🧠 Deep Learning & AI
Optimized environment for high-intensity computation:
*   **Frameworks:** Full support for `PyTorch` and `TensorFlow` via the ROCm/HIP backend.
*   **Data Science:** Production-ready `NumPy`, `Pandas`, and `Matplotlib` pre-configured in the system shell.
*   **Workflow:** Custom `nix-ld` configuration allows running unpatched pre-compiled binaries (like Conda environments or proprietary AI models) seamlessly.

### 🚀 AMD Vivado & Vitis (The Pragmatic Bridge)
This workstation solves the complex "Nix vs EDA" problem by utilizing a **Distrobox** container system.
*   The **AMD Xilinx** suite runs inside an optimized Ubuntu container for 100% binary compatibility.
*   **Native Integration:** Desktop launchers (Vivado GUI, Vitis IDE, DocNav) are mapped from the container to the host, making them feel like native NixOS applications.
*   **Hardware Access:** Kernel-level `udev` rules enable rootless JTAG and hardware-in-the-loop debugging directly from the container.

---

## 🗺️ Project Structure

```mermaid
graph TD
    Flake["flake.nix<br/>(Entry Point)"]
    
    subgraph Host["Host: MANX"]
        HostConf["configuration.nix<br/>(System Master)"]
        HostVar["variables.nix<br/>(Local Settings)"]
        HostHW["hardware.nix<br/>(Device Drivers)"]
    end

    subgraph Modules["Modular Layers"]
        Sys["System Modules<br/>(Kernel, Boot, Security)"]
        Home["Home Manager<br/>(VLSI, Shell, Neovim)"]
    end

    subgraph Secrets["Security Vault"]
        Sops["SOPS-Nix<br/>(Encryption)"]
        YAML["secrets.yaml<br/>(Encrypted)"]
    end

    Flake --> HostConf
    HostConf --> HostVar & HostHW & Sys & Home & Sops
    Sops --> YAML
```

---

## 🎮 System Orchestration (`manx` CLI)

The workstation includes a custom-built management utility, `manx`, designed for high-efficiency system maintenance and professional development workflows.

| Category | Command | Function |
| :--- | :--- | :--- |
| **System** | `manx rebuild` | Atomic sync, code formatting, and detailed package diff reporting. |
| | `manx update` | Full input synchronization and system-wide refresh. |
| | `manx rollback` | Instant restoration of the previous successful system state. |
| | `manx history` | View the chronological audit log of all system generations. |
| **Maintenance** | `manx clean` | Deep 3-layer optimization: generation pruning, GC, and hard-linking. |
| | `manx check` | Comprehensive integrity audit of the flake configuration. |
| **Development** | `manx vivado` | Enters the high-compatibility Xilinx environment. |
| | `manx edit` | Direct access to the primary system configuration in Neovim. |
| | `manx shell <pkg>` | Initialize transient, isolated development environments. |
| **Aesthetics** | `manx screensaver` | Orchestrate custom ASCII/Image branding for the workstation. |

---

## 🚀 Deployment

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/techanand8/nix-config.git ~/nix-config
    cd ~/nix-config
    ```

2.  **Initialize Local Variables:**
    ```bash
    cp hosts/manx/variables.nix.example hosts/manx/variables.nix
    # Fill in your credentials and hardware UUIDs
    ```

3.  **Apply Configuration:**
    ```bash
    # Initial bootstrap
    sudo nixos-rebuild switch --flake .#MANX

    # Subsequent updates
    manx rebuild
    ```

---

<div align="center">
  <sub>Designed for precision engineering by <b>Mayank Anand</b></sub><br/>
  <sub>Fully Declarative • Repositories are mathematically reproducible</sub>
</div>
