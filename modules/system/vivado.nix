{ pkgs, ... }:

{
  # --- CUSTOM AMD/XILINX VIVADO & HARDWARE JTAG CABLE SUPPORT ---
  # This module configures USB rules so that standard Digilent and Xilinx
  # JTAG cables work natively without root/sudo permission errors.

  services.udev.extraRules = ''
    # Xilinx Platform Cable USB / II
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0008", MODE="666"
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000d", MODE="666"
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000f", MODE="666"
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0013", MODE="666"
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0015", MODE="666"

    # Digilent USB JTAG Devices (Zybo, Zedboard, Basys, Nexys, Arty, Cmod)
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="666"
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="666"

    # FTDI-based custom JTAG programmers
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="666"
  '';
}
