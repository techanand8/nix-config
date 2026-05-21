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
  ];
}
