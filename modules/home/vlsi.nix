{ config, pkgs, vars, ... }:

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

  # --- AMD VIVADO & XILINX SUITE DESKTOP LAUNCHERS ---
  xdg.desktopEntries = {

    # 1. Vivado Native Standalone GUI
    "vivado-gui" = {
      name = "AMD Vivado ${vivadoVersion} (GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite (Standalone)";
      exec = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 2. Vivado GUI run inside Ghostty
    "vivado-gui-ghostty" = {
      name = "AMD Vivado ${vivadoVersion} (Ghostty GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite in Ghostty Terminal";
      exec = "ghostty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 3. Vivado GUI run inside Kitty
    "vivado-gui-kitty" = {
      name = "AMD Vivado ${vivadoVersion} (Kitty GUI)";
      genericName = "FPGA & EDA Design Suite";
      comment = "AMD Xilinx Vivado Design Suite in Kitty Terminal";
      exec = "kitty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 4. Vivado Interactive Tcl Shell in Ghostty
    "vivado-tcl-ghostty" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (Ghostty)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in Ghostty";
      exec = "ghostty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 5. Vivado Interactive Tcl Shell in Kitty
    "vivado-tcl-kitty" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (Kitty)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in Kitty";
      exec = "kitty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 6. Vivado Interactive Tcl Shell in xterm
    "vivado-tcl-xterm" = {
      name = "AMD Vivado ${vivadoVersion} Tcl Shell (xterm)";
      genericName = "EDA Tcl Console";
      comment = "AMD Vivado Interactive Tcl Shell in xterm";
      exec = "xterm -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vivadoPath} -mode tcl";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vivado.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 7. Vitis IDE Standalone GUI
    "vitis-gui" = {
      name = "AMD Vitis ${vivadoVersion} (GUI)";
      genericName = "Heterogeneous System IDE";
      comment = "AMD Xilinx Vitis Unified Software Platform";
      exec = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vitisPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vitis.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 8. Vitis Command Line Tool (CLI) in Default Shell
    "vitis-cli" = {
      name = "AMD Vitis ${vivadoVersion} (CLI)";
      genericName = "Vitis CLI Developer Prompt";
      comment = "AMD Xilinx Vitis CLI in current terminal";
      exec = "ghostty -e distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${vitisPath} -mode cli";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/vitis.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 9. Documentation Navigator (DocNav)
    "xilinx-docnav" = {
      name = "AMD DocNav ${vivadoVersion}";
      genericName = "Documentation Navigator";
      comment = "Xilinx Technical Documentation Search Utility";
      exec = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${docnavPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/docnav.png";
      terminal = false;
      categories = [ "Development" "Education" "Engineering" ];
    };

    # 10. Xilinx Information Center (xic - Version update checker)
    "xilinx-xic" = {
      name = "AMD Xilinx Information Center";
      genericName = "Update & Download Manager";
      comment = "Checks for Xilinx Vivado/Vitis downloads and releases";
      exec = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 ${xicPath}";
      icon = "${config.home.homeDirectory}/.local/share/icons/xilinx/xic.png";
      terminal = false;
      categories = [ "Development" "Engineering" ];
    };

    # 11. Xilinx Uninstaller (Safely remove the tools)
    "xilinx-uninstall" = {
      name = "AMD Xilinx Uninstaller";
      genericName = "Software Maintenance Tool";
      comment = "Uninstall Xilinx Vivado, Vitis and packages";
      exec = "distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/.xinstall/${vivadoVersion}/xsetup -uninstall";
      icon = "system-software-update";
      terminal = false;
      categories = [ "System" "Settings" ];
    };
  };
}
