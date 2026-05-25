{ config, pkgs, ... }:

{
  # --- OLLAMA (Local LLM Inference Engine) ---
  services.ollama = {
    enable = true;
    # Use the ROCm-enabled package for AMD GPU acceleration
    package = pkgs.ollama-rocm;
    # Automatically pull some common models on startup
    loadModels = [
      "llama3.1"
      "deepseek-coder-v2"
      "mistral"
    ];
  };

  # --- OPEN-WEBUI (Professional Frontend for Ollama) ---
  services.open-webui = {
    enable = true;
    port = 8080;
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
    # Autonomous CLI Agent (The best trusted alternative to OpenClaw)
    aider-chat-full
    # Performance monitoring for AMD GPUs (Check your VRAM usage here)
    radeontop
    rocmPackages.rocm-smi
  ];

  # --- USER-LEVEL DOCS & TRUSTED LINKS ---
  # You can access your local agents at:
  # Open-WebUI: http://localhost:8080
  # Ollama API: http://localhost:11434
}
