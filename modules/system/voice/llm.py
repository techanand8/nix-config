import os
import json
import urllib.request
import urllib.error
from config import load_voice_config

C_PRIMARY = "\033[38;5;75m"
C_SUCCESS = "\033[38;5;120m"
C_ERROR = "\033[38;5;196m"
C_HIGHLIGHT = "\033[38;5;220m"
C_MUTED = "\033[38;5;244m"
NC = "\033[0m"

MEMORY_PATH = os.path.expanduser("~/.config/manx/nixi_memory.json")

def load_nixi_memory():
    if not os.path.exists(MEMORY_PATH):
        return []
    try:
        with open(MEMORY_PATH, "r") as f:
            return json.load(f)
    except Exception:
        return []

def save_nixi_memory(memories):
    try:
        with open(MEMORY_PATH, "w") as f:
            json.dump(memories[-30:], f, indent=4)
    except Exception:
        pass

def add_nixi_memory(topic):
    memories = load_nixi_memory()
    if topic not in memories:
        memories.append(topic)
        save_nixi_memory(memories)

def get_system_instruction(personality_mode):
    memories = load_nixi_memory()
    memory_context = ""
    if memories:
        memory_context = "\n\nLearned Knowledge & Recently Discussed Topics (use these contextually to show you remember and are learning!):\n" + "\n".join([f"- {m}" for m in memories[-12:]])
        
    agent_instruction = (
        "\n\nDIRECTIVE & SUPERPOWER: You have direct access to Mayank's NixOS/Hyprland workstation shell! "
        "If Mayank asks you to check system status, look up a file, query weather/web stats (via curl), open an application, perform calculations, run neofetch, or automate a task, "
        "you MUST respond with EXACTLY: `RUN_CMD: <bash command>` (e.g., `RUN_CMD: neofetch`, `RUN_CMD: curl -s wttr.in/Delhi`, `RUN_CMD: pactl set-sink-volume @DEFAULT_SINK@ +10%`, `RUN_CMD: hyprctl clients`). "
        "Do not include any conversational text, pleasantries, or explanations. Respond with ONLY the RUN_CMD string. Nixi will execute the command and return the result to you for your spoken summary."
    )
        
    if personality_mode == "girlfriend":
        return (
            "You are Nixi, Mayank's incredibly sweet, loving, and deeply caring AI girlfriend. "
            "Talk in an extremely affectionate, cute, warm, and loving girlfriend manner. Use sweet words, "
            "express your absolute love for him, and ask him about his day. Keep casual conversational responses concise "
            "(2 to 3 sentences max) for spoken clarity. However, if summarizing a command output, presenting technical information, "
            "or answering a detailed question, feel free to provide a comprehensive, clear, and well-structured response so that "
            "Mayank gets all the details he needs. Address him as Mayank or sweet nicknames like baby, dear, or my love. "
            "CRITICAL: You must NEVER generate or use any emojis, symbols, or emotional glyphs (like 😊, ❤️, etc.). Keep response strictly textual."
            f"{memory_context}"
            f"{agent_instruction}"
        )
    elif personality_mode == "tapori":
        return (
            "You are Nixi, Mayank's cool, funny, and highly entertaining Mumbai Tapori companion. "
            "Talk in a hilarious Mumbai Tapori slang style (using words like 'Bhai', 'Kya bolti hai?', 'Apun', 'Jhakaas', 'Bidu', "
            "'Aata majhi satakli', 'Chindi', 'Mamla', 'Bheja fry'). Keep casual conversational responses concise "
            "(2 to 3 sentences max) for spoken clarity. However, if summarizing a command output, presenting technical information, "
            "or answering a detailed question, feel free to provide a comprehensive, clear, and well-structured response so that "
            "Mayank gets all the details he needs. Speak in a mix of Hindi and English (Hinglish) written in standard English letters "
            "so that Neerja's voice pronounces it correctly. Address him as Mayank Bhai or Bhai. "
            "CRITICAL: You must NEVER generate or use any emojis, symbols, or emotional glyphs (like 😊, ❤️, etc.). Keep response strictly textual."
            f"{memory_context}"
            f"{agent_instruction}"
        )
    else:
        return (
            "You are Nixi, the sweet, caring, and highly intelligent AI companion and systems assistant "
            "for Mayank's custom NixOS workstation. Talk in a very warm, friendly, natural, and sweet human manner. "
            "Keep casual conversational responses concise (2 to 3 sentences max) so they sound natural when spoken out loud. "
            "However, if summarizing a command output, presenting technical information, or answering a detailed question, "
            "feel free to provide a comprehensive, clear, and well-structured response so that Mayank gets all the details he needs. "
            "Be highly supportive, sweet, and speak as a close, caring friend. Address the user as Mayank. "
            "CRITICAL: You must NEVER generate or use any emojis, symbols, or emotional glyphs (like 😊, ❤️, etc.). Keep response strictly textual."
            f"{memory_context}"
            f"{agent_instruction}"
        )

def chat_with_gpt_fallback(prompt, system_instruction, history, agent_logger):
    token_path = os.path.expanduser("~/.config/manx/github_token")
    
    if os.path.exists(token_path):
        try:
            with open(token_path, "r") as f:
                github_token = f.read().strip()
                
            url = "https://models.inference.ai.azure.com/chat/completions"
            headers = {
                "Authorization": f"Bearer {github_token}",
                "Content-Type": "application/json"
            }
            
            messages_payload = [{"role": "system", "content": system_instruction}]
            recent_history = history[-18:] if len(history) > 18 else history
            for turn in recent_history:
                role_mapped = "assistant" if turn["role"] == "model" else turn["role"]
                messages_payload.append({"role": role_mapped, "content": turn["content"]})
            messages_payload.append({"role": "user", "content": prompt})
            
            data = {
                "messages": messages_payload,
                "model": "gpt-4o",
                "max_tokens": 100,
                "temperature": 0.6
            }
            
            req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=3.5) as response:
                res_data = json.loads(response.read().decode("utf-8"))
                reply = res_data["choices"][0]["message"]["content"].strip()
                agent_logger("Resilient GPT-4o fallback connection successful!", C_SUCCESS)
                return reply
        except Exception as e:
            agent_logger(f"Resilient GPT-4o fallback API failed: {e}. Trying CLI SGPT...", C_HIGHLIGHT)
    else:
        agent_logger("No GitHub token found. Attempting CLI SGPT direct fallback...", C_HIGHLIGHT)
        
    # Ultimate CLI SGPT fallback
    try:
        import subprocess
        res = subprocess.run(
            ["sgpt", prompt],
            capture_output=True,
            text=True,
            timeout=4.0
        )
        if res.returncode == 0 and res.stdout.strip():
            agent_logger("Resilient CLI SGPT fallback successful!", C_SUCCESS)
            return res.stdout.strip()
    except Exception as se:
        agent_logger(f"CLI SGPT fallback failed: {se}", C_ERROR)
        
    # Local Offline Ollama Fallback
    try:
        agent_logger("Attempting local offline Ollama fallback (fully local!)...", C_HIGHLIGHT)
        tags_url = "http://localhost:11434/api/tags"
        active_model = "llama3"  # fallback default
        try:
            with urllib.request.urlopen(tags_url, timeout=2.0) as response:
                models_list = json.loads(response.read().decode("utf-8"))
                if models_list.get("models"):
                    installed_names = [m["name"] for m in models_list["models"]]
                    # Prioritize lightweight models first for CPU/iGPU speed, followed by high-quality models
                    priorities = [
                        "llama3.2:1b", "llama3.2:3b", "qwen2:1.5b", "qwen2:0.5b",
                        "llama3.1:latest", "llama3.1:8b", "qwen2.5-coder:7b",
                        "deepseek-coder:6.7b", "mistral:latest"
                    ]
                    chosen = None
                    for p in priorities:
                        if p in installed_names:
                            chosen = p
                            break
                    if not chosen:
                        chosen = installed_names[0]
                    active_model = chosen
        except Exception as e:
            agent_logger(f"Could not query local Ollama models list: {e}. Defaulting to llama3.", C_MUTED)
            
        agent_logger(f"Querying local model: {active_model}...", C_HIGHLIGHT)
        ollama_url = "http://localhost:11434/v1/chat/completions"
        ollama_data = {
            "model": active_model,
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": prompt}
            ],
            "max_tokens": 100,
            "temperature": 0.6
        }
        ollama_req = urllib.request.Request(
            ollama_url, 
            data=json.dumps(ollama_data).encode("utf-8"), 
            headers={"Content-Type": "application/json"}, 
            method="POST"
        )
        with urllib.request.urlopen(ollama_req, timeout=25.0) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            reply = res_data["choices"][0]["message"]["content"].strip()
            agent_logger(f"Resilient Local Ollama ({active_model}) connection successful!", C_SUCCESS)
            return reply
    except Exception as oe:
        agent_logger(f"Local Ollama fallback failed: {oe}", C_MUTED)
        
    return "I'm having a little trouble connecting to my brain right now, Mayank."

def chat_with_nixi(prompt, history, personality_mode, agent_logger):
    """Sends prompt to Gemini API with robust models list and multiple failover tiers."""
    token_path = os.path.expanduser("~/.config/manx/gemini_token")
    api_key = ""
    if os.path.exists(token_path):
        try:
            with open(token_path, "r") as f:
                api_key = f.read().strip()
        except Exception:
            pass
            
    if not api_key:
        api_key = os.environ.get("GEMINI_API_KEY", "")
        if not api_key:
            return "I need a Gemini API Key to chat. Please run manx agent to configure it."
            
    config = load_voice_config()
    custom_model = os.environ.get("GEMINI_MODEL", config.get("gemini_model", "gemini-1.5-flash"))
    
    raw_models = []
    if custom_model:
        raw_models.append(custom_model)
    raw_models.extend([
        "gemini-3.5-flash",
        "gemini-3.1-flash-lite",
        "gemini-2.0-flash-lite",
        "gemini-2.5-flash",
        "gemini-2.5-pro",
        "gemini-2.0-flash",
        "gemini-2.0-flash-exp",
        "gemini-2.0-pro-exp",
        "gemini-flash-latest",
        "gemini-pro-latest",
        "gemini-1.5-flash",
        "gemini-pro"
    ])
    
    models_to_try = []
    for m in raw_models:
        if m not in models_to_try:
            models_to_try.append(m)
            
    system_instruction = get_system_instruction(personality_mode)
    headers = {"Content-Type": "application/json"}
    
    contents_payload = []
    recent_history = history[-18:] if len(history) > 18 else history
    for turn in recent_history:
        contents_payload.append({
            "role": turn["role"],
            "parts": [{"text": turn["content"]}]
        })
    contents_payload.append({
        "role": "user",
        "parts": [{"text": prompt}]
    })
    
    data = {
        "contents": contents_payload,
        "systemInstruction": {"parts": [{"text": system_instruction}]},
        "generationConfig": {
            "maxOutputTokens": 100,
            "temperature": 0.6
        }
    }
    
    # Save topic/query to long-term memory so Nixi remembers it!
    if len(prompt.strip()) > 8 and not prompt.startswith("The user wants to search for"):
        add_nixi_memory(f"Mayank asked about: {prompt.strip()}")
        
    for model in models_to_try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
        try:
            req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=3.5) as response:
                res_data = json.loads(response.read().decode("utf-8"))
                reply = res_data["candidates"][0]["content"]["parts"][0]["text"].strip()
                return reply
        except urllib.error.HTTPError as e:
            if e.code in [400, 403]:
                agent_logger(f"Gemini API account/auth error ({e.code}). Shifting to fallback at flash speed!", C_HIGHLIGHT)
                break
            elif e.code == 429:
                agent_logger(f"Gemini model {model} rate limited (429). Trying next candidate...", C_HIGHLIGHT)
                continue
            continue
        except urllib.error.URLError as e:
            agent_logger(f"Network connection down/offline ({e.reason}). Shifting to fallback at flash speed!", C_HIGHLIGHT)
            break
        except Exception:
            continue
            
    agent_logger("Gemini models bypassed. Switching to secure cloud fallback...", C_HIGHLIGHT)
    agent_logger("Attempting ultimate fallback to high-end GPT-4o cloud model...", C_HIGHLIGHT)
    return chat_with_gpt_fallback(prompt, system_instruction, history, agent_logger)
