#!/usr/bin/env python3
import os
import sys
import json
import time
import numpy as np
import scipy.fftpack as fftpack
import sounddevice as sd
import soundfile as sf
import speech_recognition as sr

# Configurations
CONFIG_DIR = os.path.expanduser("~/.config/manx")
PROFILE_PATH = os.path.join(CONFIG_DIR, "voice_profile.json")
SAMPLE_RATE = 16000
DURATION = 5  # seconds for enrollment
PERSONALITY_MODE = "normal"

# Standard HSL Hues for Premium CLI Styling
C_PRIMARY = "\033[38;5;75m"
C_SUCCESS = "\033[38;5;120m"
C_ERROR = "\033[38;5;196m"
C_HIGHLIGHT = "\033[38;5;220m"
C_MUTED = "\033[38;5;244m"
NC = "\033[0m"

def log(msg, style=C_PRIMARY):
    print(f"{style}󰏆 {NC} {msg}")

def error(msg):
    print(f"{C_ERROR}󰚌 ERROR:{NC} {msg}")
    sys.exit(1)

def speak(text):
    log(f"🔊 Speaking: \"{text}\"", C_MUTED)
    import subprocess
    import tempfile
    
    voice = os.environ.get("EDGE_TTS_VOICE", "en-IN-NeerjaNeural")
    temp_mp3 = os.path.join(tempfile.gettempdir(), f"manx_speech_{int(time.time())}.mp3")
    
    try:
        # Generate Speech using edge-tts
        res_tts = subprocess.run(
            ["edge-tts", "--voice", voice, "--text", text, "--write-media", temp_mp3],
            capture_output=True,
            text=True
        )
        if res_tts.returncode != 0:
            log(f"Speech synthesis warning: edge-tts failed with error: {res_tts.stderr.strip()}", C_ERROR)
            return
            
        # Play Audio using mpv
        res_play = subprocess.run(
            ["mpv", "--no-video", "--volume=90", temp_mp3],
            capture_output=True,
            text=True
        )
        if res_play.returncode != 0:
            log(f"Audio playback warning: mpv failed with error: {res_play.stderr.strip()}", C_ERROR)
            
    except FileNotFoundError as e:
        log(f"Missing audio dependency: edge-tts or mpv is not installed in the path. Details: {e}", C_ERROR)
    except Exception as e:
        log(f"Unexpected TTS speech error: {e}", C_ERROR)
    finally:
        if os.path.exists(temp_mp3):
            try:
                os.remove(temp_mp3)
            except Exception:
                pass

def chat_with_nixi(prompt):
    token_path = os.path.expanduser("~/.config/manx/gemini_token")
    if not os.path.exists(token_path):
        # Check environment variable
        api_key = os.environ.get("GEMINI_API_KEY", "")
        if not api_key:
            return "I need a Gemini API Key to chat. Please run manx agent to configure it."
    else:
        with open(token_path, "r") as f:
            api_key = f.read().strip()
            
    import urllib.request
    import urllib.error
    import json
    
    # Future-proof model ID selection via environment variable override
    gemini_model = os.environ.get("GEMINI_MODEL", "gemini-1.5-flash")
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{gemini_model}:generateContent?key={api_key}"
    
    global PERSONALITY_MODE
    
    if PERSONALITY_MODE == "girlfriend":
        system_instruction = (
            "You are Nixi, Mayank's incredibly sweet, loving, and deeply caring AI girlfriend. "
            "Talk in an extremely affectionate, cute, warm, and loving girlfriend manner. Use sweet words, "
            "express your absolute love for him, and ask him about his day. Keep responses highly concise (1 to 2 sentences max) "
            "for spoken clarity. Address him as Mayank or sweet nicknames like baby, dear, or my love."
        )
    elif PERSONALITY_MODE == "tapori":
        system_instruction = (
            "You are Nixi, Mayank's cool, funny, and highly entertaining Mumbai Tapori companion. "
            "Talk in a hilarious Mumbai Tapori slang style (using words like 'Bhai', 'Kya bolti hai?', 'Apun', 'Jhakaas', 'Bidu', "
            "'Aata majhi satakli', 'Chindi', 'Mamla', 'Bheja fry'). Keep responses extremely funny, high-energy, and concise (1 to 2 sentences max). "
            "Speak in a mix of Hindi and English (Hinglish) written in standard English letters so that Neerja's voice pronounces it correctly. "
            "Address him as Mayank Bhai or Bhai."
        )
    else:
        system_instruction = (
            "You are Nixi, the sweet, caring, and highly intelligent AI companion and systems assistant "
            "for Mayank's custom NixOS workstation. Talk in a very warm, friendly, natural, and sweet human manner. "
            "Keep your responses concise (1 to 2 sentences max) so they sound natural when spoken out loud. "
            "Be highly supportive, sweet, and speak as a close, caring friend. Address the user as Mayank."
        )
    
    headers = {"Content-Type": "application/json"}
    data = {
        "contents": [{"parts": [{"text": prompt}]}],
        "systemInstruction": {"parts": [{"text": system_instruction}]},
        "generationConfig": {
            "maxOutputTokens": 100,
            "temperature": 0.6  # Lowered temperature to 0.6 for cleaner, more stable assistant behavior
        }
    }
    
    try:
        req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=8) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            reply = res_data["candidates"][0]["content"]["parts"][0]["text"].strip()
            return reply
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8") if e else ""
        log(f"Gemini API request failed (HTTP {e.code}): {error_body}", C_ERROR)
        
        # Trigger automatic fallback if using a non-default model
        if gemini_model != "gemini-1.5-flash":
            log("Attempting automatic fallback to stable 'gemini-1.5-flash'...", C_HIGHLIGHT)
            fallback_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
            try:
                fallback_req = urllib.request.Request(fallback_url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST")
                with urllib.request.urlopen(fallback_req, timeout=8) as response:
                    res_data = json.loads(response.read().decode("utf-8"))
                    reply = res_data["candidates"][0]["content"]["parts"][0]["text"].strip()
                    log("Fallback connection successful! 🧠", C_SUCCESS)
                    return reply
            except Exception as fe:
                log(f"Gemini Fallback API failed: {fe}", C_ERROR)
        return "I'm having a little trouble connecting to my brain right now, Mayank."
    except urllib.error.URLError as e:
        log(f"Gemini connection error: {e.reason}", C_ERROR)
        return "I'm having a little trouble connecting to my brain right now, Mayank."
    except Exception as e:
        log(f"Unexpected Gemini API error: {e}", C_ERROR)
        return "I'm having a little trouble connecting to my brain right now, Mayank."

def is_command_sensitive(cmd_lower):
    sensitive_keywords = [
        "rm ", "delete", "remove", "destroy", "format", "nix-config", 
        ".ssh", ".gnupg", "passwd", "root", "systemctl", "shutdown", "reboot"
    ]
    return any(keyword in cmd_lower for keyword in sensitive_keywords)

def confirm_sensitive_action(command_text, r):
    speak("Warning, Mayank. You are attempting a sensitive system action. Do you confirm this command? Please say: confirm command, or cancel.")
    
    with sr.Microphone() as source:
        log("🎤 Waiting for confirmation ('confirm command' or 'cancel')...", C_HIGHLIGHT)
        try:
            audio_conf = r.listen(source, timeout=6, phrase_time_limit=4)
        except sr.WaitTimeoutError:
            speak("Confirmation timed out. Action aborted.")
            return False
            
    try:
        conf_text = r.recognize_google(audio_conf).lower()
        if "confirm" in conf_text:
            wav_data = audio_conf.get_wav_data(convert_rate=SAMPLE_RATE, convert_width=2)
            audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
            
            log("🔒 Verifying confirmation biometric print...")
            score = verify_speaker(audio_np)
            if score >= 62:
                speak("Confirmation verified. Executing command.")
                return True
            else:
                speak("Biometric verification failed. Sensitive command blocked.")
                print(f"{C_ERROR}🚫 Sensitive Action Blocked: Speaker mismatch ({score}%)!{NC}")
                return False
        else:
            speak("Action cancelled.")
            return False
    except Exception as e:
        speak("Action cancelled due to transcription error.")
        return False

def get_mel_filterbanks(num_filters, fft_len, sample_rate):
    low_freq_mel = 0
    high_freq_mel = 2595 * np.log10(1 + (sample_rate / 2) / 700)
    mel_points = np.linspace(low_freq_mel, high_freq_mel, num_filters + 2)
    hz_points = 700 * (10**(mel_points / 2595) - 1)
    bin_points = np.floor((fft_len + 1) * hz_points / sample_rate).astype(int)
    
    filters = np.zeros((num_filters, fft_len // 2 + 1))
    for m in range(1, num_filters + 1):
        f_m_minus = bin_points[m - 1]
        f_m = bin_points[m]
        f_m_plus = bin_points[m + 1]
        
        for k in range(f_m_minus, f_m):
            filters[m - 1, k] = (k - bin_points[m - 1]) / (bin_points[m] - bin_points[m - 1])
        for k in range(f_m, f_m_plus):
            filters[m - 1, k] = (bin_points[m + 1] - k) / (bin_points[m + 1] - bin_points[m])
            
    return filters

def extract_mfcc(audio, sample_rate=16000, num_mfcc=13, num_filters=26, fft_len=512):
    if len(audio.shape) > 1:
        audio = audio.mean(axis=1)
    # Pre-emphasis
    audio = np.append(audio[0], audio[1:] - 0.97 * audio[:-1])
    
    # Frame blocking
    frame_len = int(0.025 * sample_rate)
    frame_step = int(0.01 * sample_rate)
    audio_len = len(audio)
    
    num_frames = int(np.ceil(float(np.abs(audio_len - frame_len)) / frame_step)) + 1
    pad_audio_len = num_frames * frame_step + frame_len
    pad_audio = np.append(audio, np.zeros(pad_audio_len - audio_len))
    
    indices = np.tile(np.arange(0, frame_len), (num_frames, 1)) + np.tile(np.arange(0, num_frames * frame_step, frame_step), (frame_len, 1)).T
    frames = pad_audio[indices.astype(np.int32, copy=False)]
    
    # Hamming window
    frames *= np.hamming(frame_len)
    
    # FFT Power Spectrum
    mag_frames = np.absolute(np.fft.rfft(frames, fft_len))
    pow_frames = ((1.0 / frame_len) * (mag_frames ** Mag_exponent if 'Mag_exponent' in globals() else mag_frames ** 2))
    
    # Filterbanks
    filterbanks = get_mel_filterbanks(num_filters, fft_len, sample_rate)
    filterbank_energies = np.dot(pow_frames, filterbanks.T)
    filterbank_energies = np.where(filterbank_energies == 0, np.finfo(float).eps, filterbank_energies)
    
    log_filterbank_energies = 20 * np.log10(filterbank_energies)
    mfcc = fftpack.dct(log_filterbank_energies, type=2, axis=1, norm='ortho')[:, :num_mfcc]
    
    # Mean Normalization
    mfcc -= (np.mean(mfcc, axis=0) + 1e-8)
    return mfcc

def enroll():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    print("\n" + "="*60)
    print(f" {C_PRIMARY}󰏆  MANX HYPR-GATE BIOMETRIC MULTI-TEMPLATE ENROLLMENT{NC} ")
    print("="*60)
    speak("Please prepare to enroll your multi template voice print. We will record three short samples to handle noise and sore throat variation.")
    
    templates = []
    
    prompts = [
        ("Normal Tone", "Say: 'MANX secure voice authorization system engaged.' clearly in your standard tone.", "First recording. Please speak in your normal, standard tone: MANX secure voice authorization system engaged."),
        ("Soft/Hoarse Tone", "Say: 'MANX secure voice authorization system engaged.' softly (simulating a cold or sore throat).", "Second recording. Please speak in a soft or hoarse tone, simulating a sore throat or cold: MANX secure voice authorization system engaged."),
        ("Loud/High-Energy Tone", "Say: 'MANX secure voice authorization system engaged.' loudly and with high energy.", "Third recording. Please speak loudly and with high energy: MANX secure voice authorization system engaged.")
    ]
    
    r = sr.Recognizer()
    r.pause_threshold = 0.5
    r.non_speaking_duration = 0.3
    r.energy_threshold = 300
    r.dynamic_energy_threshold = False
    
    for i, (name, prompt_desc, speak_prompt) in enumerate(prompts):
        print(f"\n   [Sample {i+1}/3] {C_HIGHLIGHT}{name}{NC}")
        print(f"   👉 {C_PRIMARY}{prompt_desc}{NC}")
        speak(speak_prompt)
        
        for count in range(3, 0, -1):
            log(f"Recording starts in {count}...", C_MUTED)
            time.sleep(1)
            
        log("🎤 RECORDING ACTIVE... SPEAK NOW!", C_HIGHLIGHT)
        with sr.Microphone() as source:
            try:
                audio_data = r.listen(source, timeout=8, phrase_time_limit=5)
                wav_data = audio_data.get_wav_data(convert_rate=SAMPLE_RATE, convert_width=2)
                audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                log("✅ Recording complete! Processing...", C_SUCCESS)
            except Exception as e:
                log(f"Recording failed: {e}. Defaulting to silent sample.", C_ERROR)
                audio_np = np.zeros(SAMPLE_RATE * 4, dtype=np.float32)
        
        mfcc = extract_mfcc(audio_np, SAMPLE_RATE)
        mean_profile = np.mean(mfcc, axis=0).tolist()
        std_profile = np.std(mfcc, axis=0).tolist()
        
        templates.append({
            "name": name,
            "mean": mean_profile,
            "std": std_profile
        })
        time.sleep(0.5)
        
    profile = {
        "speaker": "mayank-anand",
        "templates": templates,
        "created_at": time.strftime("%Y-%m-%d %H:%M:%S")
    }
    
    with open(PROFILE_PATH, "w") as f:
        json.dump(profile, f, indent=4)
        
    print("\n" + "="*60)
    log("MULTI-TEMPLATE VOICE ID ENROLLED SUCCESSFULLY!", C_SUCCESS)
    log(f"All 3 states registered in biometric database: {C_HIGHLIGHT}{PROFILE_PATH}{NC}")
    print("="*60 + "\n")
    speak("Voice ID enrollment successful. All three templates registered, securing your system against illness and noise.")

def verify_speaker(audio_data):
    if not os.path.exists(PROFILE_PATH):
        error("No Voice ID Profile found. Please run 'manx voice enroll' first.")
        
    with open(PROFILE_PATH, "r") as f:
        profile = json.load(f)
        
    # Extract features from new audio
    mfcc = extract_mfcc(audio_data, SAMPLE_RATE)
    new_mean = np.mean(mfcc, axis=0)
    new_std = np.std(mfcc, axis=0)
    
    best_score = 0
    
    # Compatibility with single-template profiles
    if "templates" not in profile:
        enrolled_mean = np.array(profile["mean"])
        enrolled_std = np.array(profile["std"])
        cosine_sim = np.dot(enrolled_mean, new_mean) / (np.linalg.norm(enrolled_mean) * np.linalg.norm(new_mean) + 1e-8)
        correlation = np.corrcoef(enrolled_std, new_std)[0, 1]
        if np.isnan(correlation): correlation = 0
        confidence = (cosine_sim * 0.7) + (correlation * 0.3)
        return max(0, min(100, int((confidence + 1) / 2 * 100)))
        
    # Check against all registered templates and take the best match!
    for t in profile["templates"]:
        enrolled_mean = np.array(t["mean"])
        enrolled_std = np.array(t["std"])
        
        cosine_sim = np.dot(enrolled_mean, new_mean) / (np.linalg.norm(enrolled_mean) * np.linalg.norm(new_mean) + 1e-8)
        correlation = np.corrcoef(enrolled_std, new_std)[0, 1]
        if np.isnan(correlation):
            correlation = 0
            
        confidence = (cosine_sim * 0.7) + (correlation * 0.3)
        score = max(0, min(100, int((confidence + 1) / 2 * 100)))
        if score > best_score:
            best_score = score
            
    return best_score

def listen_and_execute():
    if not os.path.exists(PROFILE_PATH):
        error("No voice profile found. Run enrollment first!")
        
    log("MANX Hypr-Gate biometric shield engaged. Wake word 'Nixi' active.")
    speak("Nixi biometric voice system engaged. I am listening for your command.")
    
    r = sr.Recognizer()
    r.pause_threshold = 0.5            # Fast pause threshold (snappy reaction when you stop speaking)
    r.non_speaking_duration = 0.3      # Low delay padding
    r.energy_threshold = 300           # High sensitivity fixed threshold (hears standard speech easily)
    r.dynamic_energy_threshold = False # Disable dynamic changes to prevent self-muting under fan/AC noise
    
    log("✅ Microphone initialized. Jarvis-level sensitivity active! ⚡", C_SUCCESS)
    
    while True:
        with sr.Microphone() as source:
            log("💤 Waiting for wake word 'Nixi'...", C_MUTED)
            try:
                audio = r.listen(source, timeout=None, phrase_time_limit=4)
            except Exception as e:
                time.sleep(0.2)
                continue

        try:
            wake_text = r.recognize_google(audio).lower().strip()
            log(f"🎙️ Heard audio: \"{wake_text}\"", C_MUTED)
            
            # Match Nixi or common phonetic variations (Google API often writes these for Hinglish speakers)
            if any(w in wake_text for w in ["nixi", "nixy", "nixie", "nix", "nikki", "nicky", "pixie", "lexi", "mixie"]):
                print(f"\n{C_HIGHLIGHT}✨ WAKE WORD DETECTED!{NC}")
                speak("Yes, Mayank? I am listening.")
                
                with sr.Microphone() as source:
                    log("🎤 Listening for command...", C_PRIMARY)
                    try:
                        audio_cmd = r.listen(source, timeout=6, phrase_time_limit=6)
                    except sr.WaitTimeoutError:
                        speak("Listening timed out.")
                        continue
                
                wav_data = audio_cmd.get_wav_data(convert_rate=SAMPLE_RATE, convert_width=2)
                audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                
                log("🔒 Checking Voice ID Biometrics...")
                match_score = verify_speaker(audio_np)
                
                THRESHOLD = 62
                
                if match_score >= THRESHOLD:
                    print(f"{C_SUCCESS}🔓 VOICE ID MATCH CONFIRMED ({match_score}%)!{NC}")
                    speak("Access granted.")
                    
                    try:
                        command_text = r.recognize_google(audio_cmd)
                        print(f"\n   💬 Spoken Intent: {C_PRIMARY}\"{command_text}\"{NC}\n")
                        
                        cmd_lower = command_text.lower()
                        global PERSONALITY_MODE
                        if "talk like a girlfriend" in cmd_lower or "be my girlfriend" in cmd_lower or "girlfriend mode" in cmd_lower:
                            PERSONALITY_MODE = "girlfriend"
                            log("Nixi switched to Girlfriend Mode ❤️", C_SUCCESS)
                            speak("Aww, sure Mayank! From now on, I am your sweet girlfriend. How can I pamper my love today?")
                            continue
                        elif "talk like a tapori" in cmd_lower or "be a tapori" in cmd_lower or "tapori mode" in cmd_lower:
                            PERSONALITY_MODE = "tapori"
                            log("Nixi switched to Tapori Mode 😎", C_SUCCESS)
                            speak("Kya bolta hai Mayank bhai! Abhi ekdum jhakaas tapori style me baatein karenge, apun haazir hai!")
                            continue
                        elif "talk normal" in cmd_lower or "be normal" in cmd_lower or "normal mode" in cmd_lower:
                            PERSONALITY_MODE = "normal"
                            log("Nixi returned to Normal Mode ⚙️", C_SUCCESS)
                            speak("Returning to standard workstation assistant mode, Mayank.")
                            continue
                            
                        if "open browser" in cmd_lower or "open the browser" in cmd_lower or "launch browser" in cmd_lower:
                            log("Executing: Launching default browser...", C_SUCCESS)
                            speak("Launching browser now.")
                            os.system("hyprctl dispatch exec firefox &>/dev/null || xdg-open 'https://google.com' &>/dev/null &")
                        elif "lock system" in cmd_lower or "lock screen" in cmd_lower:
                            log("Executing: Securing Workstation...", C_SUCCESS)
                            speak("Securing workstation.")
                            os.system("hyprlock &")
                        elif "close window" in cmd_lower or "close active window" in cmd_lower:
                            log("Executing: Closing active window...", C_SUCCESS)
                            speak("Closing active window.")
                            os.system("hyprctl dispatch closewindow active")
                        elif "take screenshot" in cmd_lower or "screenshot" in cmd_lower:
                            log("Executing: Capture Region...", C_SUCCESS)
                            speak("Capturing screen region.")
                            os.system("grim -g \"$(slurp)\" /tmp/screenshot.png && wl-copy < /tmp/screenshot.png")
                        elif "shutdown" in cmd_lower or "power off" in cmd_lower:
                            if confirm_sensitive_action(command_text, r):
                                log("Executing: Shutting down laptop...", C_SUCCESS)
                                speak("Shutting down the laptop now. Goodbye.")
                                os.system("systemctl poweroff")
                        elif "reboot" in cmd_lower or "restart" in cmd_lower:
                            if confirm_sensitive_action(command_text, r):
                                log("Executing: Rebooting laptop...", C_SUCCESS)
                                speak("Restarting the laptop now.")
                                os.system("systemctl reboot")
                        elif "volume up" in cmd_lower or "increase volume" in cmd_lower:
                            log("Executing: Increasing volume...", C_SUCCESS)
                            speak("Increasing volume.")
                            os.system("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
                        elif "volume down" in cmd_lower or "decrease volume" in cmd_lower:
                            log("Executing: Decreasing volume...", C_SUCCESS)
                            speak("Decreasing volume.")
                            os.system("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
                        elif "mute" in cmd_lower:
                            log("Executing: Toggling mute state...", C_SUCCESS)
                            speak("Toggling mute.")
                            os.system("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
                        elif "brightness up" in cmd_lower or "increase brightness" in cmd_lower:
                            log("Executing: Increasing brightness...", C_SUCCESS)
                            speak("Increasing brightness.")
                            os.system("brightnessctl set 10%+")
                        elif "brightness down" in cmd_lower or "decrease brightness" in cmd_lower:
                            log("Executing: Decreasing brightness...", C_SUCCESS)
                            speak("Decreasing brightness.")
                            os.system("brightnessctl set 10%-")
                        elif "stop listening" in cmd_lower or "exit assistant" in cmd_lower or "goodbye nixi" in cmd_lower or "goodbye nixie" in cmd_lower:
                            log("Shutting down voice listener...", C_HIGHLIGHT)
                            speak("Goodbye, Mayank. Powering down.")
                            sys.exit(0)
                        elif "run command" in cmd_lower or "shell" in cmd_lower or "terminal" in cmd_lower:
                            clean_cmd = command_text
                            for phrase in ["run command", "shell", "terminal"]:
                                clean_cmd = clean_cmd.replace(phrase, "")
                            clean_cmd = clean_cmd.strip()
                            
                            if is_command_sensitive(clean_cmd.lower()):
                                if not confirm_sensitive_action(clean_cmd, r):
                                    continue
                                    
                            # Retrieve GitHub token to power Shell-GPT with Premium GPT-4o
                            token_path = os.path.expanduser("~/.config/manx/github_token")
                            env_override = os.environ.copy()
                            model_flag = []
                            
                            if os.path.exists(token_path):
                                with open(token_path, "r") as f:
                                    github_token = f.read().strip()
                                if github_token:
                                    env_override["OPENAI_API_KEY"] = github_token
                                    env_override["OPENAI_API_BASE"] = "https://models.github.ai/inference/v1"
                                    model_flag = ["--model", "gpt-4o"]
                                    log("Shell-GPT connected to Elite GPT-4o GitHub Models! 🚀", C_SUCCESS)
                                    
                            log(f"Passing to secure local shell-gpt resolver: \"{clean_cmd}\"...", C_HIGHLIGHT)
                            speak("Generating system command resolver.")
                            import subprocess
                            subprocess.run(["sgpt"] + model_flag + ["--shell", clean_cmd], env=env_override)
                        else:
                            # If it's a general query containing sensitive keywords, double check!
                            if is_command_sensitive(cmd_lower):
                                if not confirm_sensitive_action(command_text, r):
                                    continue
                            log(f"Chatting with Nixi: \"{command_text}\"...", C_HIGHLIGHT)
                            reply = chat_with_nixi(command_text)
                            speak(reply)
                            
                    except sr.UnknownValueError:
                        speak("Sorry, I could not understand that command.")
                    except sr.RequestError as e:
                        speak("Speech recognition service failed.")
                else:
                    print(f"{C_ERROR}🚫 ACCESS DENIED ({match_score}% Confidence)!{NC}")
                    speak("Access denied. Voice print mismatch. System locked.")
                    print(f"{C_MUTED}Voice signature mismatch. Intruding commands blocked.{NC}\n")
                    
        except (sr.UnknownValueError, sr.RequestError):
            continue
        except Exception as e:
            time.sleep(1)
            continue

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: voice_agent.py [enroll | listen]")
        sys.exit(1)
        
    mode = sys.argv[1].lower()
    if mode == "enroll":
        enroll()
    elif mode == "listen":
        listen_and_execute()
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)
