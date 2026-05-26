#!/usr/bin/env bash
# Runs the SDDM theme in test mode with locale override to fix qtvirtualkeyboard segfaults
export LC_CTYPE=en_US.UTF-8
sddm-greeter-qt6 --test-mode --theme /home/mayank-anand/nix-config/modules/system/sddm-theme
