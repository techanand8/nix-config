{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  # Centralized version inherited dynamically from hosts/manx/variables.nix
  vivadoVersion = vars.vivadoVersion;
  vivadoPath = "/tools/Xilinx/${vivadoVersion}/Vivado/bin/vivado";
  vitisPath = "/tools/Xilinx/${vivadoVersion}/Vitis/bin/vitis";
  docnavPath = "/tools/Xilinx/DocNav/docnav";
  xicPath = "/tools/Xilinx/xic/xic";
in
{
  # --- PROFESSIONAL VLSI & ENGINEERING TOOLS ---
  home.packages = with pkgs; [
    # --- VLSI TOOLS (DV & PD focus) ---
    iverilog
    verilator
    gtkwave
    surfer
    yosys
    magic-vlsi
    klayout
    ngspice
    ghdl
    opencl-headers
    netlistsvg
    circt # Circuit IR compilers and tools (MLIR-based hardware design)
    haskellPackages.sv2v # SystemVerilog to Verilog conversion
    sv-lang # SystemVerilog compiler and language services
    bluespec # Toolchain for the Bluespec Hardware Definition Language
    openocd # Open On-Chip Debugging (JTAG/SWD support)
    lcov # Code coverage tool for verification tracking

    # --- ADVANCED DV, RTL, SV/UVM, VHDL & FORMAL ---
    surelog # SystemVerilog compiler/elaborator (Full UVM & SV parser support)
    nvc # High-performance VHDL compiler & simulator
    xschem # Schematic capture for VLSI & mixed-signal designs
    netgen # LVS (Layout Vs Schematic) verification tool
    svls # SystemVerilog Language Server
    svlint # SystemVerilog linter
    verible # Google's SystemVerilog developer tools (linter/formatter/indexer)
    veryl # Modern hardware design language (SV alternative)
    sby # Front-end driver for Yosys-based formal verification (formerly symbiyosys)
    z3 # High-performance theorem prover & SMT solver (Formal backend)
    cvc5 # High-performance theorem prover & SMT solver (Formal backend)
    yices # High-performance theorem prover & SMT solver (Formal backend)
    bitwuzla # SMT solver for bit-vectors and arrays (Formal backend)
    python3Packages.scapy # Packet manipulation (Network-on-Chip/Protocol DV)
    python3Packages.wavedrom # Digital waveform generator & renderer (Python CLI package)
    python3Packages.cocotb # Coroutine-based cosimulation framework for DV
    python3Packages.cocotb-bus # AXI/APB/AHB bus protocol extensions for cocotb
    python3Packages.pyverilog # Python-based Verilog parsing, elaboration & AST tools (DFT/DV scripting)
    python3Packages.pysmt # Python interface to SMT solvers (Custom Formal DV)
    python3Packages.pyspice # Python-based interface to NGSpice (Mixed-Signal DV)
    systemc # SystemC C++ library for architectural & Transaction-Level DV

    # --- INDUSTRIAL PROJECT MANAGEMENT ---
    fusesoc # Package manager and build system for HDL cores
    python3Packages.edalize # Abstraction library for interfacing with EDA tools (used by FuseSoC)

    # --- ARCHITECTURE-SPECIFIC & EMBEDDED DESIGN ---
    # RISC-V Toolchain, Simulation & Formal ISA
    pkgsCross.riscv64-embedded.buildPackages.gcc # RISC-V 64-bit Embedded GCC
    (pkgsCross.riscv64-embedded.buildPackages.gdb.overrideAttrs (oldAttrs: {
      versionCheckProgram = "${placeholder "out"}/bin/riscv64-none-elf-gdb";
    })) # RISC-V 64-bit Embedded GDB
    spike # RISC-V ISA Simulator (Standard for architectural exploration)
    pkgsCross.riscv64.riscv-pk # RISC-V Proxy Kernel (Required for Spike)
    rars # RISC-V Assembler and Runtime Simulator (Educational IDE)
    sail # Sail ISA specification language (Used for formal RISC-V model generation)

    # ARM Toolchain & Simulation
    (lib.lowPrio gcc-arm-embedded) # ARM Embedded GCC (arm-none-eabi)
    qemu_full # Full system and user-mode emulation for RISC-V/ARM (Full build for engineering)

    # --- ADVANCED PHYSICAL DESIGN & ASIC FLOWS ---
    openroad # OpenROAD project: autonomous physical design flow (Includes OpenSTA)
    yosys-ghdl # GHDL plugin for Yosys (VHDL synthesis support)
    python3Packages.gdsfactory # Python-based layout and routing for PD
    urjtag # Universal JTAG library, server and tools (Boundary Scan & DFT)
    openfpgaloader # Universal utility for programming FPGAs (JTAG Support)
  ];

  # --- AMD VIVADO & XILINX SUITE DESKTOP LAUNCHERS ---
  xdg.desktopEntries = {

    # 1. Vivado Native Standalone GUI
    "vivado-gui" = {
      name = "AMD Vivado ${vivadoVersion} (GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite (Standalone)";
      exec = "distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 2. Vivado GUI run inside Ghostty
    "vivado-gui-ghostty" = {
      name = "AMD Vivado ${vivadoVersion} (Ghostty GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite in Ghostty Terminal";
      exec = "ghostty -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 3. Vivado GUI run inside Kitty
    "vivado-gui-kitty" = {
      name = "AMD Vivado ${vivadoVersion} (Kitty GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite in Kitty Terminal";
      exec = "kitty -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 4. Vivado Interactive Tcl Shell in Ghostty
    "vivado-tcl-ghostty" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (Ghostty)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in Ghostty";
      exec = "ghostty -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 5. Vivado Interactive Tcl Shell in Kitty
    "vivado-tcl-kitty" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (Kitty)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in Kitty";
      exec = "kitty -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 6. Vivado Interactive Tcl Shell in xterm
    "vivado-tcl-xterm" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (xterm)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in xterm";
      exec = "xterm -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 7. Vitis IDE Standalone GUI
    "vitis-gui" = {
      name = "AMD Vitis ${vivadoVersion} (GUI)";
      genericName = "Heterogeneous System IDE";
      comment = "AMD Xilinx Vitis Unified Software Platform";
      exec = "distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vitisPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vitis.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 8. Vitis Command Line Tool (CLI) in Default Shell
    "vitis-cli" = {
      name = "AMD Vitis ${vivadoVersion} (CLI)";
      genericName = "Vitis CLI Developer Prompt";
      comment = "AMD Xilinx Vitis CLI in current terminal";
      exec = "ghostty -e distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vitisPath} -mode cli";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/vitis.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 9. Documentation Navigator (DocNav)
    "xilinx-docnav" = {
      name = "AMD DocNav ${vivadoVersion}";
      genericName = "Documentation Navigator";
      comment = "Xilinx Technical Documentation Search Utility";
      exec = "distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${docnavPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/docnav.png";
      terminal = false;
      categories = [
        "Development"
        "Education"
        "Engineering"
      ];
    };

    # 10. Xilinx Information Center (xic - Version update checker)
    "xilinx-xic" = {
      name = "AMD Xilinx Information Center";
      genericName = "Update & Download Manager";
      comment = "Checks for Xilinx Vivado/Vitis downloads and releases";
      exec = "distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${xicPath}";
      icon = "/home/${vars.username}/.local/share/icons/xilinx/xic.png";
      terminal = false;
      categories = [
        "Development"
        "Engineering"
      ];
    };

    # 11. Xilinx Uninstaller (Safely remove the tools)
    "xilinx-uninstall" = {
      name = "AMD Xilinx Uninstaller";
      genericName = "Software Maintenance Tool";
      comment = "Uninstall Xilinx Vivado, Vitis and packages";
      exec = "distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/.xinstall/${vivadoVersion}/xsetup -uninstall";
      icon = "system-software-update";
      terminal = false;
      categories = [
        "System"
        "Settings"
      ];
    };
  };
}
