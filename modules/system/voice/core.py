import os
import sys
import json
import time
import queue
import subprocess
import hashlib
import threading
import numpy as np
import sounddevice as sd
import speech_recognition as sr

from config import CONFIG_DIR, PROFILE_PATH, load_voice_config
from biometrics import extract_mfcc, verify_speaker, match_wakeword, adapt_voice_profile
from intents import IntentDispatcher
from llm import chat_with_nixi

C_PRIMARY = "\033[38;5;75m"
C_SUCCESS = "\033[38;5;120m"
C_ERROR = "\033[38;5;196m"
C_HIGHLIGHT = "\033[38;5;220m"
C_MUTED = "\033[38;5;244m"
NC = "\033[0m"

class NixiSynth:
    @staticmethod
    def play(effect_name, silent=False):
        if silent:
            return
            
        def _play():
            try:
                sample_rate = 16000
                if effect_name == "activate":
                    # Beautiful high-tech sci-fi rising dual tone chime
                    duration = 0.4
                    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
                    freq = 350 + 750 * (t / duration) ** 2
                    envelope = np.sin(np.pi * t / duration) * np.exp(-3 * t / duration)
                    wave = (np.sin(2 * np.pi * freq * t) + 0.4 * np.sin(4 * np.pi * freq * t)) * envelope
                    
                elif effect_name == "deactivate":
                    # Beautiful descending fade sweep
                    duration = 0.5
                    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
                    freq = 880 - 680 * (t / duration)
                    envelope = np.exp(-5 * t / duration)
                    wave = (np.sin(2 * np.pi * freq * t) + 0.3 * np.sin(1.5 * np.pi * freq * t)) * envelope
                    
                elif effect_name == "access_granted":
                    # Double-beep success high tone chime
                    duration = 0.35
                    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
                    wave = np.zeros_like(t)
                    b1 = (t >= 0) & (t < 0.12)
                    wave[b1] = np.sin(2 * np.pi * 880 * t[b1]) * np.exp(-12 * t[b1])
                    b2 = (t >= 0.15) & (t < 0.32)
                    wave[b2] = np.sin(2 * np.pi * 1100 * (t[b2] - 0.15)) * np.exp(-12 * (t[b2] - 0.15))
                    
                elif effect_name == "access_denied":
                    # Low buzz warning chord with dynamic modulation
                    duration = 0.5
                    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
                    wave = np.zeros_like(t)
                    b1 = (t >= 0) & (t < 0.18)
                    wave[b1] = (np.sin(2 * np.pi * 110 * t[b1]) + 0.4 * np.sin(2 * np.pi * 220 * t[b1])) * np.exp(-4 * t[b1])
                    b2 = (t >= 0.22) & (t < 0.42)
                    wave[b2] = (np.sin(2 * np.pi * 110 * (t[b2] - 0.22)) + 0.4 * np.sin(2 * np.pi * 220 * (t[b2] - 0.22))) * np.exp(-4 * (t[b2] - 0.22))
                    
                elif effect_name == "thinking":
                    # Futuristic radar pulse
                    duration = 0.25
                    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
                    wave = np.sin(2 * np.pi * 920 * t) * np.exp(-16 * t)
                    
                else:
                    return
                
                wave = wave / (np.max(np.abs(wave)) + 1e-8) * 0.22
                sd.play(wave.astype(np.float32), sample_rate)
                sd.wait()
            except Exception:
                pass
        
        threading.Thread(target=_play, daemon=True).start()

class NixiAgent:
    def __init__(self):
        self.config = load_voice_config()
        self.personality_mode = "normal"
        self.silent_mode = False
        self.current_voice = self.config.get("edge_tts_voice", "en-IN-NeerjaNeural")
        self.conversation_history = []
        self.active_mpv = None
        self.dispatcher = IntentDispatcher(self)
        self.sample_rate = self.config.get("sample_rate", 16000)
        self.prewarm_tts_cache()

    def play_sound_effect(self, effect_name):
        NixiSynth.play(effect_name, self.silent_mode)


    def log(self, msg, style=C_PRIMARY):
        print(f"{style}[NIXI]{NC} {msg}")

    def notify(self, title, message, timeout=2000):
        """Displays a desktop notification on Hyprland/Linux environment."""
        try:
            subprocess.run(["notify-send", title, message, "-t", str(timeout)], capture_output=True)
        except Exception:
            pass

    def prewarm_tts_cache(self):
        def warm():
            phrases = [
                "Yes, Mayank? I am listening.",
                "Access granted.",
                "Access denied. Voice print mismatch.",
                "Listening timed out.",
                "Alright, going to sleep. Call me if you need me!",
                "Securing workstation.",
                "Closing active window.",
                "Capturing screen region."
            ]
            cache_dir = os.path.expanduser("~/.cache/manx_voice")
            os.makedirs(cache_dir, exist_ok=True)
            
            voices = ["en-IN-NeerjaNeural", "en-IN-MadhurNeural", "en-US-AvaNeural", "en-US-AndrewNeural"]
            for voice in voices:
                for p in phrases:
                    text_hash = hashlib.md5(f"{p.lower().strip()}_{voice}".encode("utf-8")).hexdigest()
                    cached_path = os.path.join(cache_dir, f"{text_hash}.mp3")
                    if not os.path.exists(cached_path):
                        subprocess.run(
                            ["edge-tts", "--voice", voice, "--text", p, "--write-media", cached_path],
                            capture_output=True
                        )
        threading.Thread(target=warm, daemon=True).start()

    def stop_speaking(self):
        if self.active_mpv:
            try:
                self.active_mpv.terminate()
                self.active_mpv.wait(timeout=1)
            except Exception:
                try:
                    self.active_mpv.kill()
                except Exception:
                    pass
            self.active_mpv = None

    def is_speaking(self):
        if self.active_mpv:
            if self.active_mpv.poll() is None:
                return True
            else:
                self.active_mpv = None
        return False

    def speak(self, text):
        self.stop_speaking()
        
        if self.silent_mode:
            self.log(f"[SILENT MODE] Nixi: \"{text}\"", C_MUTED)
            return
            
        self.log(f"Speaking: \"{text}\"", C_MUTED)
        
        cache_dir = os.path.expanduser("~/.cache/manx_voice")
        os.makedirs(cache_dir, exist_ok=True)
        
        clean_text = text.lower().strip()
        text_hash = hashlib.md5(f"{clean_text}_{self.current_voice}".encode("utf-8")).hexdigest()
        cached_path = os.path.join(cache_dir, f"{text_hash}.mp3")
        
        if os.path.exists(cached_path) and os.path.getsize(cached_path) > 0:
            try:
                self.active_mpv = subprocess.Popen(
                    ["mpv", "--no-video", "--volume=90", cached_path],
                    stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
                return
            except Exception as e:
                self.log(f"Cache audio failed: {e}. Synthesizing...", C_ERROR)
                
        try:
            rate = self.config.get("edge_tts_rate", "-4%")
            pitch = self.config.get("edge_tts_pitch", "+0Hz")
            res_tts = subprocess.run(
                ["edge-tts", "--voice", self.current_voice, "--rate", rate, "--pitch", pitch, "--text", text, "--write-media", cached_path],
                capture_output=True, text=True
            )
            if res_tts.returncode == 0:
                self.active_mpv = subprocess.Popen(
                    ["mpv", "--no-video", "--volume=90", cached_path],
                    stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
        except Exception as e:
            self.log(f"TTS synthesis failed: {e}", C_ERROR)

    def confirm_sensitive_action(self, command_text):
        self.speak("Warning, Mayank. You are attempting a sensitive system action. Do you confirm this command? Please say: confirm command, or cancel.")
        
        r = sr.Recognizer()
        with sr.Microphone() as source:
            self.log("🎤 Waiting for confirmation ('confirm command' or 'cancel')...", C_HIGHLIGHT)
            self.notify("Nixi Security Shield", "Waiting for confirmation ('confirm command'/'cancel')")
            try:
                audio_conf = r.listen(source, timeout=6, phrase_time_limit=4)
            except sr.WaitTimeoutError:
                self.speak("Confirmation timed out. Action aborted.")
                self.notify("Nixi Security Shield", "Confirmation timed out. Action aborted.", 3000)
                return False
                
        try:
            conf_text = r.recognize_google(audio_conf).lower()
            if "confirm" in conf_text:
                wav_data = audio_conf.get_wav_data(convert_rate=self.sample_rate, convert_width=2)
                audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                
                self.log("🔒 Verifying confirmation biometric print...")
                score = verify_speaker(audio_np, self.sample_rate)
                threshold = self.config.get("speaker_threshold", 62)
                
                if score >= threshold:
                    self.speak("Confirmation verified. Executing command.")
                    self.notify("Nixi Security Shield", f"Access Granted ({score}%)", 2000)
                    return True
                else:
                    self.speak("Biometric verification failed. Sensitive command blocked.")
                    self.log(f"🚫 Sensitive Action Blocked: Speaker mismatch ({score}%)!", C_ERROR)
                    self.notify("Nixi Security Shield", f"Access Denied: Mismatch ({score}%)", 3000)
                    return False
            else:
                self.speak("Action cancelled.")
                self.notify("Nixi Security Shield", "Action cancelled.", 2000)
                return False
        except Exception:
            self.speak("Action cancelled due to transcription error.")
            self.notify("Nixi Security Shield", "Action cancelled due to error.", 2000)
            return False

    def enroll(self):
        os.makedirs(CONFIG_DIR, exist_ok=True)
        print("\n" + "="*65)
        print(f" {C_PRIMARY}󰏆  MANX HYPR-GATE BIOMETRIC MULTI-TEMPLATE ENROLLMENT{NC} ")
        print("="*65)
        self.speak("Please prepare to enroll your multi template voice print. We will record three short samples to handle noise and sore throat variation.")
        
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
            self.speak(speak_prompt)
            
            for count in range(3, 0, -1):
                self.log(f"Recording starts in {count}...", C_MUTED)
                time.sleep(1)
                
            self.log("🎤 RECORDING ACTIVE... SPEAK NOW!", C_HIGHLIGHT)
            with sr.Microphone() as source:
                try:
                    audio_data = r.listen(source, timeout=8, phrase_time_limit=5)
                    wav_data = audio_data.get_wav_data(convert_rate=self.sample_rate, convert_width=2)
                    audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                    self.log("✅ Recording complete! Processing...", C_SUCCESS)
                except Exception as e:
                    self.log(f"Recording failed: {e}. Defaulting to silent sample.", C_ERROR)
                    audio_np = np.zeros(self.sample_rate * 4, dtype=np.float32)
            
            mfcc = extract_mfcc(audio_np, self.sample_rate)
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
            
        self.log("SPEAKER VOICE ID ENROLLED SUCCESSFULLY!", C_SUCCESS)
        
        # --- REGISTER CUSTOM WAKE-WORD TEMPLATES ---
        self.speak("Biometric voice print enrolled. Now, let's register your custom wake-word. Please prepare to speak the wake-word, Nixi, three times.")
        
        wakeword_templates = []
        for i in range(3):
            print(f"\n   [Wake Word Sample {i+1}/3]")
            self.speak(f"Please say: Nixi, now.")
            
            for count in range(2, 0, -1):
                self.log(f"Recording in {count}...", C_MUTED)
                time.sleep(1)
                
            self.log("🎤 Speak now...", C_HIGHLIGHT)
            with sr.Microphone() as source:
                try:
                    audio_data = r.listen(source, timeout=5, phrase_time_limit=2)
                    wav_data = audio_data.get_wav_data(convert_rate=self.sample_rate, convert_width=2)
                    audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                    self.log("✅ Received sample! Processing...", C_SUCCESS)
                except Exception as e:
                    self.log(f"Recording failed: {e}. Skipping.", C_ERROR)
                    continue
            
            mfcc = extract_mfcc(audio_np, self.sample_rate)
            wakeword_templates.append({
                "mfcc": mfcc.tolist()
            })
            time.sleep(0.5)
            
        profile["wakeword_templates"] = wakeword_templates
        
        with open(PROFILE_PATH, "w") as f:
            json.dump(profile, f, indent=4)
            
        self.speak("Voice ID enrollment successful. All templates registered, securing your workstation against illness, noise, and unauthorized triggers.")

    def listen_and_execute(self):
        if not os.path.exists(PROFILE_PATH):
            print(f"{C_ERROR}[ERROR]{NC} No voice profile found. Run 'manx voice enroll' first!")
            sys.exit(1)
            
        self.notify("Nixi Voice Engine", "Biometric wake-word engine engaged.")
        self.speak("Nixi biometric voice system engaged. I am listening for your command.")
        
        r = sr.Recognizer()
        r.pause_threshold = 0.5
        r.non_speaking_duration = 0.3
        r.energy_threshold = 300
        r.dynamic_energy_threshold = True
        
        self.log("🎤 Voice-activity assisted wake-word engine active. Say 'Nixi'...", C_SUCCESS)
        
        with sr.Microphone() as source:
            self.log("Adjusting for ambient noise...", C_MUTED)
            r.adjust_for_ambient_noise(source, duration=1.0)
            self.log(f"Calibrated energy threshold: {r.energy_threshold:.2f}", C_MUTED)
            
            while True:
                try:
                    self.log("Listening for wake word 'Nixi'...", C_MUTED)
                    audio = r.listen(source, timeout=None, phrase_time_limit=4)
                    self.stop_speaking()
                    
                    wav_data = audio.get_wav_data(convert_rate=self.sample_rate, convert_width=2)
                    audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                    
                    spoken_text = ""
                    try:
                        spoken_text = r.recognize_google(audio).lower().strip()
                        self.log(f"Heard: '{spoken_text}'", C_MUTED)
                    except sr.UnknownValueError:
                        continue
                    except Exception as e:
                        self.log(f"Transcription service error: {e}. Trying local offline biometrics...", C_MUTED)
                        score = match_wakeword(audio_np, self.sample_rate)
                        threshold = self.config.get("wakeword_threshold", 65.0)
                        if score >= threshold:
                            spoken_text = "nixi"
                        else:
                            continue
                            
                    # Check if the wake-word is present
                    wake_matched = False
                    wake_synonyms = ["nixi", "niksi", "nixie", "niks", "nix", "pixie", "nikki"]
                    for synonym in wake_synonyms:
                        if synonym in spoken_text:
                            wake_matched = True
                            break
                            
                    if wake_matched:
                        # Biometric Speaker Verification
                        self.log("🔒 Checking wake-word speaker biometric print...")
                        score = verify_speaker(audio_np, self.sample_rate)
                        threshold = self.config.get("speaker_threshold", 62)
                        
                        if score >= threshold:
                            self.log(f"🔥 Wake word MATCH CONFIRMED ({score}%)!", C_SUCCESS)
                            self.play_sound_effect("activate")
                            self.notify("Nixi Assistant", f"Access Granted ({score}%)")
                            
                            # Adapt voice profile dynamically
                            adapt_voice_profile(audio_np, self.sample_rate)
                            
                            # Check if they said a command along with the wake word (One-Breath Triggering)
                            command_part = spoken_text
                            for synonym in wake_synonyms:
                                command_part = command_part.replace(synonym, "")
                            command_part = command_part.strip()
                            
                            if len(command_part) > 2:
                                self.log(f"Direct command detected: '{command_part}'", C_HIGHLIGHT)
                                self.notify("Nixi Assistant", f"Direct command: {command_part}")
                                handled = self.dispatcher.dispatch(command_part)
                                if not handled:
                                    self.log(f"Chatting with Nixi: \"{command_part}\"...", C_HIGHLIGHT)
                                    self.notify("Nixi Assistant", "Thinking...")
                                    reply = chat_with_nixi(command_part, self.conversation_history, self.personality_mode, self.log)
                                    self.conversation_history.append({"role": "user", "content": command_part})
                                    self.conversation_history.append({"role": "model", "content": reply})
                                    if len(self.conversation_history) > 40:
                                        self.conversation_history = self.conversation_history[-40:]
                                    self.speak(reply)
                            else:
                                self.speak("Yes, Mayank? I am listening.")
                                
                            self.conversational_loop()
                        else:
                            self.log(f"🚫 Wake word blocked: Biometric mismatch ({score}%)!", C_ERROR)
                            self.play_sound_effect("access_denied")
                            self.notify("Nixi Security", f"Access Denied: Voice Mismatch ({score}%)", 3000)
                            
                except Exception as e:
                    self.log(f"Error in wake-word main loop: {e}", C_ERROR)
                    time.sleep(0.5)

    def conversational_loop(self):
        r = sr.Recognizer()
        r.pause_threshold = 0.5
        r.non_speaking_duration = 0.3
        r.energy_threshold = 300
        r.dynamic_energy_threshold = True
        
        conversation_active = True
        
        with sr.Microphone() as source:
            while conversation_active:
                self.log("Listening for follow-up command...", C_PRIMARY)
                try:
                    audio_cmd = r.listen(source, timeout=6, phrase_time_limit=8)
                    self.stop_speaking()
                except sr.WaitTimeoutError:
                    self.log("Conversation timed out. Going back to sleep...", C_MUTED)
                    self.play_sound_effect("deactivate")
                    self.notify("Nixi Assistant", "Going back to sleep.")
                    conversation_active = False
                    break
                except Exception as e:
                    self.log(f"Microphone error: {e}", C_ERROR)
                    conversation_active = False
                    break
                    
                wav_data = audio_cmd.get_wav_data(convert_rate=self.sample_rate, convert_width=2)
                audio_np = np.frombuffer(wav_data, dtype=np.int16).astype(np.float32) / 32768.0
                
                self.log("Checking Voice ID Biometrics...")
                match_score = verify_speaker(audio_np, self.sample_rate)
                
                threshold = self.config.get("speaker_threshold", 62)
                if match_score >= threshold:
                    self.log(f"VOICE ID MATCH CONFIRMED ({match_score}%)!", C_SUCCESS)
                    
                    adapt_voice_profile(audio_np, self.sample_rate)
                    
                    try:
                        command_text = r.recognize_google(audio_cmd)
                        print(f"\n   Spoken Intent: {C_PRIMARY}\"{command_text}\"{NC}\n")
                        
                        cmd_lower = command_text.lower().strip()
                        if any(w in cmd_lower for w in ["go to sleep", "goodbye", "bye", "stop listening", "chup", "silent", "stop", "sleep"]):
                            self.speak("Alright, going to sleep. Call me if you need me!")
                            self.play_sound_effect("deactivate")
                            self.notify("Nixi Assistant", "Going back to sleep.")
                            conversation_active = False
                            break
                            
                        # Dispatch command intent
                        handled = self.dispatcher.dispatch(command_text)
                        if not handled:
                            self.log(f"Chatting with Nixi: \"{command_text}\"...", C_HIGHLIGHT)
                            self.notify("Nixi Assistant", "Thinking...")
                            reply = chat_with_nixi(command_text, self.conversation_history, self.personality_mode, self.log)
                            
                            self.conversation_history.append({"role": "user", "content": command_text})
                            self.conversation_history.append({"role": "model", "content": reply})
                            if len(self.conversation_history) > 40:
                                self.conversation_history = self.conversation_history[-40:]
                                
                            self.speak(reply)
                            
                        self.log("Continued conversation active. Keep talking naturally...", C_HIGHLIGHT)
                    except Exception as e:
                        self.log(f"Could not understand audio: {e}", C_MUTED)
                        continue
                else:
                    self.log(f"ACCESS DENIED ({match_score}% Confidence)!", C_ERROR)
                    self.play_sound_effect("access_denied")
                    self.notify("Nixi Assistant", f"Access Denied: Voice Mismatch ({match_score}%)", 3000)
                    self.speak("Access denied. Voice print mismatch.")
                    conversation_active = False
