import os
import json

CONFIG_DIR = os.path.expanduser("~/.config/manx")
PROFILE_PATH = os.path.join(CONFIG_DIR, "voice_profile.json")
VOICE_JSON_PATH = os.path.join(CONFIG_DIR, "voice.json")

DEFAULT_CONFIG = {
    "sample_rate": 16000,
    "enroll_duration": 5,
    "sensitive_keywords": [
        "rm ", "delete", "remove", "destroy", "format", "nix-config", 
        ".ssh", ".gnupg", "passwd", "root", "systemctl", "shutdown", "reboot"
    ],
    "edge_tts_voice": "en-IN-NeerjaNeural",
    "gemini_model": "gemini-1.5-flash",
    "speaker_threshold": 62,
    "wakeword_threshold": 65.0,  # DTW alignment confidence threshold
    "wakeword_len_sec": 1.2      # Short wake-word window size
}

def load_voice_config():
    """Loads voice configuration, generating default JSON if missing."""
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if not os.path.exists(VOICE_JSON_PATH):
        try:
            with open(VOICE_JSON_PATH, "w") as f:
                json.dump(DEFAULT_CONFIG, f, indent=4)
        except Exception:
            pass
        return DEFAULT_CONFIG
    
    try:
        with open(VOICE_JSON_PATH, "r") as f:
            user_config = json.load(f)
            # Ensure all keys are present by building on top of defaults
            for key, val in DEFAULT_CONFIG.items():
                if key not in user_config:
                    user_config[key] = val
            return user_config
    except Exception:
        return DEFAULT_CONFIG

def get_sensitive_keywords():
    config = load_voice_config()
    return config.get("sensitive_keywords", DEFAULT_CONFIG["sensitive_keywords"])
