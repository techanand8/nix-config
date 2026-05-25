{ config, pkgs, ... }:

{
  # --- OLLAMA (Local LLM Inference Engine) ---
  services.ollama = {
    enable = true;
    # Use the ROCm-enabled package for AMD GPU acceleration
    package = pkgs.ollama-rocm;

    # --- AMD LAPTOP STABILITY FIX ---
    # Many mobile AMD GPUs (like 680M/780M) need this override to prevent
    # the display driver from crashing/blinking when running ROCm.
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # Standard stable override for most modern AMD APUs
    };

    # Automatically pull high-intelligence models on startup
    # Curated for stability & professional engineering:
    # 1. deepseek-coder:6.7b  - High-speed engineering model (VRAM Optimized)
    # 2. llama3.1             - The 8B gold standard for emails
    # 3. qwen2.5-coder:7b     - Fast logic and reasoning model
    # 4. mistral              - Lightweight speedster
    loadModels = [
      "deepseek-coder:6.7b"
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
    # Ctags required for Aider's Repo-map functionality
    universal-ctags
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
