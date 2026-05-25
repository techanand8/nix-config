{ config, pkgs, ... }:

{
  # --- OLLAMA (Local LLM Inference Engine) ---
  services.ollama = {
    enable = true;
    # Use the ROCm-enabled package for AMD GPU acceleration
    package = pkgs.ollama-rocm;
    # Automatically pull high-intelligence models on startup
    # Smartest configuration for professional engineering:
    # 1. deepseek-coder-v2 - Top-tier 16B model for Verilog/Coding (Smartest Free)
    # 2. llama3.1          - The 8B gold standard for emails and general tasks
    # 3. qwen2.5-coder:7b  - Newest high-efficiency logic and reasoning model
    loadModels = [
      "deepseek-coder-v2"
      "llama3.1"
      "qwen2.5-coder:7b"
      "mistral"
    ];
  };

  # --- OPEN-WEBUI (Professional Frontend for Ollama) ---
  services.open-webui = {
    enable = true;
    port = 8081;
    # Connect to the local Ollama instance
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable telemetry for 100% privacy
      WEBUI_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  # --- SYSTEM PACKAGES FOR AI ---
  environment.systemPackages = with pkgs; [
    # Autonomous CLI Agent (Best for coding & file editing)
    aider-chat-full
    # OpenClaw (General purpose agent for tasks like emails/planning)
    openclaw
    # Performance monitoring for AMD GPUs (Check your VRAM usage here)
    radeontop
    rocmPackages.rocm-smi
  ];

  # --- USER-LEVEL DOCS & TRUSTED LINKS ---
  # You can access your local agents at:
  # Open-WebUI: http://localhost:8081 (Chat)
  # OpenClaw: http://localhost:8082 (General Agent)
  # Ollama API: http://localhost:11434 (Backend)
}
