{
  config,
  pkgs,
  lib,
  ...
}:

{
  # --- OLLAMA (Local LLM Inference Engine) ---
  services.ollama = {
    enable = true;
    # Use the ROCm-enabled package for AMD GPU acceleration
    package = pkgs.ollama-rocm;

    # --- AMD STABILITY FIX (BARCELO / GFX90C) ---
    # Your GPU (Barcelo [1002:15e7]) is based on GFX90C (Vega).
    # The 9.0.0 override is the most stable fallback for this architecture.
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "9.0.0";
      OLLAMA_KEEP_ALIVE = "5m";
      HSA_ENABLE_SDMA = "0"; # Improved stability on Vega/Barcelo APUs
    };

    # Automatically pull high-intelligence models on startup
    # Curated for stability & professional engineering:
    # 1. deepseek-coder:6.7b  - High-speed engineering model (VRAM Optimized)
    # 2. llama3.1             - The 8B gold standard for emails
    # 3. qwen2.5-coder:7b     - Fast logic and reasoning model
    # 4. mistral              - Lightweight speedster
    loadModels = [
      "gemma4:12b"
      "deepseek-coder:6.7b"
      "llama3.1"
      "qwen2.5-coder:7b"
      "mistral"
      "llama3.2:1b"
    ];
  };

  # --- OPEN-WEBUI (Professional Frontend for Ollama) ---
  services.open-webui = {
    enable = true;
    port = 8081;
    environmentFile = "/var/lib/open-webui/open-webui.env";
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
    # Performance monitoring for AMD GPUs (Check your VRAM usage here)
    radeontop
    rocmPackages.rocm-smi

    # Python environment for AI scripting (Pre-baked with common libraries)
    (python3.withPackages (
      ps: with ps; [
        openai
        anthropic
        google-generativeai
        litellm
        huggingface-hub
        pydantic
        matplotlib
        ipython
        httpx
        aiohttp
        beautifulsoup4
        selenium
        pandas
        numpy
      ]
    ))
  ];

  # --- USER-LEVEL DOCS & TRUSTED LINKS ---
  # You can access your local agents at:
  # Open-WebUI: http://localhost:8081 (Chat)
  # Ollama API: http://localhost:11434 (Backend)

  # --- SYSTEMD OVERRIDES ---
  # Force Ollama to use a static user for persistence compatibility
  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ollama";
    Group = "ollama";
  };

  # Force Open-WebUI to use a static user for persistence compatibility
  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "open-webui";
    Group = "open-webui";
  };

  # Create the static users
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    home = "/var/lib/ollama";
  };
  users.groups.ollama = { };

  users.users.open-webui = {
    isSystemUser = true;
    group = "open-webui";
    home = "/var/lib/open-webui";
  };
  users.groups.open-webui = { };
}
