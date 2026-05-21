{ config, pkgs, ... }:

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

    # --- ADVANCED DV, RTL, SV/UVM, VHDL & FORMAL ---
    surelog # SystemVerilog compiler/elaborator (Full UVM & SV parser support)
    nvc # High-performance VHDL compiler & simulator
    xschem # Schematic capture for VLSI & mixed-signal designs
    # netgen # LVS (Layout Vs Schematic) verification tool (Temporarily disabled due to upstream Python 3.13 pybind11 compile bug)
    svls # SystemVerilog Language Server
    svlint # SystemVerilog linter
    verible # Google's SystemVerilog developer tools (linter/formatter)
    veryl # Modern hardware design language (SV alternative)
    sby # Front-end driver for Yosys-based formal verification (formerly symbiyosys)
    python3Packages.wavedrom # Digital waveform generator & renderer (Python CLI package)
  ];
}
