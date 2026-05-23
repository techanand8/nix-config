{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # --- Python Ecosystem (VLSI & AI focus) ---
    python314 # System Default
    python314Packages.pip
    (lib.lowPrio python313) # Professional Stable (Low priority to avoid bin conflicts)
    (lib.lowPrio python313Packages.pip)
    (lib.lowPrio python312) # For Project Compatibility
    (lib.lowPrio python312Packages.pip)
    uv # Fast Python package manager
    pipx # Isolated Python tools
    python3Packages.virtualenv
    python3Packages.cocotb # Coroutine-based cosimulation (VLSI)
    python3Packages.setuptools
    python3Packages.numpy
    python3Packages.matplotlib
    python3Packages.pandas

    # --- Rust & Node.js ---
    rustup # Rust toolchain manager
    nodejs_latest # Modern Node.js

    # --- Java Ecosystem ---
    jdk # Latest Stable Java

    # --- C/C++ Ecosystem ---
    (lib.hiPrio gcc) # GNU Compiler Collection (High priority to win over clang)
    (lib.lowPrio clang) # LLVM-based compiler (Low priority to avoid bin/c++ conflict with gcc)
    (lib.lowPrio llvm) # LLVM toolchain (Low priority just in case)
    cmake # Modern build system
    gnumake # Classic build tool
    ninja # High-speed build system
    systemc # SystemC for hardware modeling

    # --- Vivado & EDA Host Support (Libraries) ---
    (lib.lowPrio ncurses5)
    zlib
    libGL
    libGLU
    libX11
    libXext
    libXrender
    libXi
    libXtst
    libXft
    glib

    # --- VLSI Scripting & Automation ---
    perl # Essential for many VLSI toolchains
    tcl # Essential for EDA tools
    expect # Tcl-based automation

    # --- AI/ML Infrastructure ---
    clinfo # Verify OpenCL support
  ];
}
