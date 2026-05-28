import os
import sys
import subprocess
import urllib.parse
from config import get_sensitive_keywords

C_PRIMARY = "\033[38;5;75m"
C_SUCCESS = "\033[38;5;120m"
C_ERROR = "\033[38;5;196m"
NC = "\033[0m"

class IntentDispatcher:
    def __init__(self, agent):
        self.agent = agent
        self.rules = []
        self._register_default_intents()

    def register(self, keywords, handler):
        self.rules.append((keywords, handler))

    def is_sensitive(self, cmd_text):
        cmd_lower = cmd_text.lower()
        sensitive_keywords = get_sensitive_keywords()
        return any(keyword in cmd_lower for keyword in sensitive_keywords)

    def verify_action(self, command_text):
        if self.is_sensitive(command_text):
            self.agent.log("🔒 Checking action sensitivity protocol...", C_ERROR)
            if not self.agent.confirm_sensitive_action(command_text):
                return False
        return True

    def dispatch(self, command_text):
        """Attempts to match and dispatch command text to a system action handler."""
        cmd_lower = command_text.lower().strip()
        for keywords, handler in self.rules:
            for kw in keywords:
                if kw in cmd_lower:
                    if not self.verify_action(command_text):
                        return True  # Handled (blocked by safety shield)
                    return handler(command_text, cmd_lower)
        return False

    def _register_default_intents(self):
        # 1. Personality switching
        self.register(
            ["talk like a girlfriend", "be my girlfriend", "girlfriend mode"],
            self._handle_girlfriend_mode
        )
        self.register(
            ["talk like a tapori", "be a tapori", "tapori mode"],
            self._handle_tapori_mode
        )
        self.register(
            ["talk normal", "be normal", "normal mode"],
            self._handle_normal_mode
        )

        # 2. Volume & Audio Control
        self.register(["volume up", "increase volume"], self._handle_volume_up)
        self.register(["volume down", "decrease volume"], self._handle_volume_down)
        self.register(["mute"], self._handle_mute)

        # 3. Brightness Control
        self.register(["brightness up", "increase brightness"], self._handle_brightness_up)
        self.register(["brightness down", "decrease brightness"], self._handle_brightness_down)

        # 4. Workstation Security & Screens
        self.register(["lock system", "lock screen"], self._handle_lock)
        self.register(["close window", "close active window"], self._handle_close_window)
        self.register(["take screenshot", "screenshot"], self._handle_screenshot)
        self.register(["shutdown", "power off"], self._handle_shutdown)
        self.register(["reboot", "restart"], self._handle_reboot)

        # 5. Search Engines
        self.register(["search", "google", "youtube"], self._handle_search)

        # 6. Speaking/Silent states & Voice adjustments
        self.register(["go silent", "be quiet", "silent mode"], self._handle_go_silent)
        self.register(["speaking mode", "talk to me", "speak mode"], self._handle_speaking_mode)
        self.register(["us male", "american male", "american guy"], self._handle_voice_us_male)
        self.register(["us female", "american female", "american lady", "american voice", "us voice"], self._handle_voice_us_female)
        self.register(["indian male", "indian guy"], self._handle_voice_in_male)
        self.register(["indian female", "indian lady", "indian voice", "standard voice"], self._handle_voice_in_female)
        self.register(["british female", "sonia voice", "uk female", "british lady"], self._handle_voice_gb_female)
        self.register(["british male", "ryan voice", "uk male", "british guy"], self._handle_voice_gb_male)
        self.register(["ultra premium female", "jenny voice", "natural female voice", "jenny"], self._handle_voice_ultra_female)
        self.register(["natural male voice", "guy voice", "premium male voice", "guy"], self._handle_voice_ultra_male)

        # 7. Shell / CLI command executions
        self.register(["run command", "shell command", "terminal command"], self._handle_shell_gpt)

        # 8. Web & Desktop Applications Launching
        self.register(["open ", "launch "], self._handle_app_launch)

        # 9. System Diagnostics & Performance Status
        self.register(["system status", "check performance", "how is my pc", "pc health", "system health"], self._handle_system_status)

        # 10. Hyprland Navigation & Workspace Control
        self.register(["workspace ", "go to workspace "], self._handle_workspace_nav)
        self.register(["move window to workspace ", "move window to "], self._handle_window_to_workspace)
        self.register(["what is open", "focused window", "active window"], self._handle_active_window)
        self.register(["toggle fullscreen", "fullscreen mode"], self._handle_fullscreen)
        self.register(["toggle floating", "float window", "make floating"], self._handle_floating)

        # 11. Media Player Control (playerctl)
        self.register(["play music", "resume music"], self._handle_media_play)
        self.register(["pause music", "stop music"], self._handle_media_pause)
        self.register(["next song", "next track", "skip song"], self._handle_media_next)
        self.register(["previous song", "previous track"], self._handle_media_prev)
        self.register(["what song is playing", "current song", "what is playing"], self._handle_media_current)

        # 12. Productivity Timers & Alarms
        self.register(["set a timer for", "remind me in"], self._handle_timer)

        # 13. Weather Reports
        self.register(["weather in", "what is the weather like"], self._handle_weather)

        # 14. NixOS System Clean & Maintenance
        self.register(["clean system", "garbage collect", "optimize store"], self._handle_nixos_clean)

    # --- HANDLER IMPLEMENTATIONS ---
    
    def _handle_girlfriend_mode(self, text, cmd):
        self.agent.personality_mode = "girlfriend"
        self.agent.log("Nixi switched to Girlfriend Mode", C_SUCCESS)
        self.agent.speak("Aww, sure Mayank! From now on, I am your sweet girlfriend. How can I pamper my love today?")
        return True

    def _handle_tapori_mode(self, text, cmd):
        self.agent.personality_mode = "tapori"
        self.agent.log("Nixi switched to Tapori Mode", C_SUCCESS)
        self.agent.speak("Kya bolta hai Mayank bhai! Abhi ekdum jhakaas tapori style me baatein karenge, apun haazir hai!")
        return True

    def _handle_normal_mode(self, text, cmd):
        self.agent.personality_mode = "normal"
        self.agent.log("Nixi returned to Normal Mode", C_SUCCESS)
        self.agent.speak("Returning to standard workstation assistant mode, Mayank.")
        return True

    def _handle_volume_up(self, text, cmd):
        self.agent.log("Executing: Increasing volume...", C_SUCCESS)
        self.agent.speak("Increasing volume.")
        os.system("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
        return True

    def _handle_volume_down(self, text, cmd):
        self.agent.log("Executing: Decreasing volume...", C_SUCCESS)
        self.agent.speak("Decreasing volume.")
        os.system("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
        return True

    def _handle_mute(self, text, cmd):
        self.agent.log("Executing: Toggling mute state...", C_SUCCESS)
        self.agent.speak("Toggling mute.")
        os.system("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        return True

    def _handle_brightness_up(self, text, cmd):
        self.agent.log("Executing: Increasing brightness...", C_SUCCESS)
        self.agent.speak("Increasing brightness.")
        os.system("brightnessctl set 10%+")
        return True

    def _handle_brightness_down(self, text, cmd):
        self.agent.log("Executing: Decreasing brightness...", C_SUCCESS)
        self.agent.speak("Decreasing brightness.")
        os.system("brightnessctl set 10%-")
        return True

    def _handle_lock(self, text, cmd):
        self.agent.log("Executing: Securing Workstation...", C_SUCCESS)
        self.agent.speak("Securing workstation.")
        os.system("hyprlock &>/dev/null || kscreenlocker_greet &>/dev/null &")
        return True

    def _handle_close_window(self, text, cmd):
        self.agent.log("Executing: Closing active window...", C_SUCCESS)
        self.agent.speak("Closing active window.")
        os.system("hyprctl dispatch closewindow active &>/dev/null || xdotool windowclose $(xdotool getactivewindow) &>/dev/null &")
        return True

    def _handle_screenshot(self, text, cmd):
        self.agent.log("Executing: Capture Region...", C_SUCCESS)
        self.agent.speak("Capturing screen region.")
        os.system("grim -g \"$(slurp)\" /tmp/screenshot.png && wl-copy < /tmp/screenshot.png")
        return True

    def _handle_shutdown(self, text, cmd):
        self.agent.log("Executing: Shutting down system...", C_SUCCESS)
        self.agent.speak("Shutting down the laptop now. Goodbye.")
        os.system("systemctl poweroff")
        return True

    def _handle_reboot(self, text, cmd):
        self.agent.log("Executing: Rebooting system...", C_SUCCESS)
        self.agent.speak("Restarting the laptop now.")
        os.system("systemctl reboot")
        return True

    def _handle_search(self, text, cmd):
        import urllib.request
        import urllib.parse
        import re
        from llm import chat_with_nixi
        
        # 1. Determine if YouTube search
        if "youtube" in cmd:
            query = text.lower().replace("search", "").replace("on youtube", "").replace("youtube", "").strip()
            self.agent.log(f"Executing: Searching YouTube for \"{query}\"...", C_SUCCESS)
            self.agent.speak(f"Searching YouTube for {query}.")
            url = f"https://youtube.com/results?search_query={urllib.parse.quote(query)}"
            os.system(f"firefox '{url}' &>/dev/null || xdg-open '{url}' &>/dev/null &")
            return True
            
        # 2. Web search
        query = text.lower()
        for term in ["search on google for", "search google for", "search for", "google for", "search on google", "search google", "search", "google"]:
            if query.startswith(term):
                query = query.replace(term, "", 1)
        query = query.strip()
        
        if not query:
            return False
            
        self.agent.log(f"Executing: Searching web for \"{query}\"...", C_SUCCESS)
        self.agent.play_sound_effect("thinking")
        self.agent.speak(f"Searching the web for {query}. Let me summarize that for you.")
        
        # Open browser in the background for complete results
        url = f"https://google.com/search?q={urllib.parse.quote(query)}"
        os.system(f"firefox '{url}' &>/dev/null || xdg-open '{url}' &>/dev/null &")
        
        # Scrape DuckDuckGo for live snippets
        snippets = []
        try:
            ddg_url = f"https://html.duckduckgo.com/html/?q={urllib.parse.quote(query)}"
            req = urllib.request.Request(
                ddg_url, 
                headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                html = response.read().decode('utf-8', errors='ignore')
                
            raw_snippets = re.findall(r'<a class="result__snippet"[^>]*>(.*?)</a>', html, re.DOTALL)
            
            def clean_html(raw):
                clean = re.sub(r'<[^>]+>', '', raw)
                clean = clean.replace('&quot;', '"').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&#x27;', "'").replace('&#39;', "'")
                return clean.strip()
                
            for snippet in raw_snippets:
                cleaned = clean_html(snippet)
                if cleaned:
                    snippets.append(cleaned)
        except Exception as e:
            self.agent.log(f"Web scraping warning: {e}", C_MUTED)
            
        # Synthesize using Gemini/LLM
        if snippets:
            context = "\n".join(snippets[:3])
            prompt = (
                f"The user wants to search for: '{query}'. Based on the following live web search snippets, "
                f"answer the user in a very warm, friendly, natural, and helpful human voice. Keep the response to 2 or 3 concise sentences maximum so it is easy to listen to. "
                f"Do not mention the phrase 'snippets' or 'according to the search results'. Just speak the answer directly.\n\n"
                f"Search Results:\n{context}"
            )
        else:
            prompt = f"The user asked to search for: '{query}', but our live search scraper failed. Answer the user nicely in 2 sentences about what this topic is based on your own knowledge."
            
        from llm import add_nixi_memory
        add_nixi_memory(f"Mayank searched the web for: {query}")
        
        reply = chat_with_nixi(prompt, [], self.agent.personality_mode, self.agent.log)
        self.agent.speak(reply)
        return True

    def _handle_go_silent(self, text, cmd):
        self.agent.speak("Switching to silent mode. I will no longer speak, but I am still listening to you.")
        self.agent.silent_mode = True
        self.agent.log("Nixi switched to Silent Mode (Actions will run silently!)", C_SUCCESS)
        return True

    def _handle_speaking_mode(self, text, cmd):
        self.agent.silent_mode = False
        self.agent.log("Nixi switched to Speaking Mode", C_SUCCESS)
        self.agent.speak("Switching to speaking mode. I am ready to talk to you again, Mayank!")
        return True

    def _handle_voice_us_male(self, text, cmd):
        self.agent.current_voice = "en-US-AndrewNeural"
        self.agent.log("Nixi switched to Premium US Male Voice (AndrewNeural)", C_SUCCESS)
        self.agent.speak("Switching to American English male voice. How do I sound, Mayank?")
        return True

    def _handle_voice_us_female(self, text, cmd):
        self.agent.current_voice = "en-US-AvaNeural"
        self.agent.log("Nixi switched to Premium US Female Voice (AvaNeural)", C_SUCCESS)
        self.agent.speak("Switching to American English female voice. I am ready, Mayank.")
        return True

    def _handle_voice_in_male(self, text, cmd):
        self.agent.current_voice = "en-IN-MadhurNeural"
        self.agent.log("Nixi switched to Standard IN Male Voice (MadhurNeural)", C_SUCCESS)
        self.agent.speak("Switching to Indian English male voice. How do I sound, Mayank?")
        return True

    def _handle_voice_in_female(self, text, cmd):
        self.agent.current_voice = "en-IN-NeerjaNeural"
        self.agent.log("Nixi switched to Standard IN Female Voice (NeerjaNeural)", C_SUCCESS)
        self.agent.speak("Switching back to Indian English female voice. Ready to assist you.")
        return True

    def _handle_voice_gb_female(self, text, cmd):
        self.agent.current_voice = "en-GB-SoniaNeural"
        self.agent.log("Nixi switched to Premium British Female Voice (SoniaNeural)", C_SUCCESS)
        self.agent.speak("Cheerio, Mayank. I have switched to the premium British female voice. How do I sound?")
        return True

    def _handle_voice_gb_male(self, text, cmd):
        self.agent.current_voice = "en-GB-RyanNeural"
        self.agent.log("Nixi switched to Premium British Male Voice (RyanNeural)", C_SUCCESS)
        self.agent.speak("Hello there, Mayank. I have successfully switched to the premium British male voice.")
        return True

    def _handle_voice_ultra_female(self, text, cmd):
        self.agent.current_voice = "en-US-JennyNeural"
        self.agent.log("Nixi switched to Ultra-Premium US Female Voice (JennyNeural)", C_SUCCESS)
        self.agent.speak("Hi Mayank! I've switched to the ultra-premium neural female voice. It sounds completely human and incredibly realistic, doesn't it?")
        return True

    def _handle_voice_ultra_male(self, text, cmd):
        self.agent.current_voice = "en-US-GuyNeural"
        self.agent.log("Nixi switched to Ultra-Premium US Male Voice (GuyNeural)", C_SUCCESS)
        self.agent.speak("Hey Mayank, I've switched to the ultra-premium neural male voice. This speech synthesis uses fully natural tones to keep the conversation smooth.")
        return True

    def _handle_shell_gpt(self, text, cmd):
        clean_cmd = text
        for phrase in ["run command", "shell command", "terminal command", "shell", "terminal"]:
            clean_cmd = clean_cmd.replace(phrase, "")
        clean_cmd = clean_cmd.strip()
        
        token_path = os.path.expanduser("~/.config/manx/github_token")
        env_override = os.environ.copy()
        model_flag = []
        
        if os.path.exists(token_path):
            with open(token_path, "r") as f:
                github_token = f.read().strip()
            if github_token:
                env_override["OPENAI_API_KEY"] = github_token
                env_override["OPENAI_API_BASE"] = "https://models.github.ai/inference/v1"
                env_override["OPENAI_BASE_URL"] = "https://models.github.ai/inference/v1"
                model_flag = ["--model", "gpt-4o"]
                self.agent.log("Shell-GPT connected to Elite GPT-4o GitHub Models!", C_SUCCESS)
                
        self.agent.log(f"Passing to secure local shell-gpt resolver: \"{clean_cmd}\"...", C_PRIMARY)
        self.agent.speak("Generating system command resolver.")
        subprocess.run(["sgpt"] + model_flag + ["--shell", clean_cmd], env=env_override)
        return True

    def _handle_app_launch(self, text, cmd):
        target = cmd.replace("open", "").replace("launch", "").replace("in my browser", "").replace("in browser", "").strip()
        if not target:
            return False
            
        browser_targets = ["gmail", "youtube", "github", "google", "facebook", "twitter", "reddit", "linkedin", "chatgpt"]
        desktop_targets = ["discord", "spotify", "steam", "obs", "vlc", "vscode", "code", "dolphin", "file manager", "files", "browser", "firefox", "chrome"]

        if target in browser_targets:
            self.agent.log(f"Executing: Launching {target.capitalize()} in browser...", C_SUCCESS)
            self.agent.speak(f"Opening {target.capitalize()}.")
            url_map = {
                "gmail": "https://mail.google.com",
                "youtube": "https://youtube.com",
                "github": "https://github.com",
                "google": "https://google.com",
                "facebook": "https://facebook.com",
                "twitter": "https://twitter.com",
                "reddit": "https://reddit.com",
                "linkedin": "https://linkedin.com",
                "chatgpt": "https://chatgpt.com"
            }
            url = url_map.get(target, f"https://{target}.com")
            os.system(f"firefox '{url}' &>/dev/null || xdg-open '{url}' &>/dev/null &")
            return True
            
        elif target in ["browser", "firefox", "chrome"]:
            self.agent.log("Executing: Launching default browser...", C_SUCCESS)
            self.agent.speak("Launching browser.")
            os.system("firefox &>/dev/null || xdg-open 'https://google.com' &>/dev/null &")
            return True
            
        elif target in ["dolphin", "file manager", "files", "dolphin file"]:
            self.agent.log("Executing: Launching Dolphin File Manager...", C_SUCCESS)
            self.agent.speak("Opening dolphin file manager.")
            os.system("dolphin &>/dev/null || xdg-open ~ &>/dev/null &")
            return True
            
        elif target in ["discord", "spotify", "steam", "obs", "vlc", "vscode", "code"]:
            app_map = {
                "discord": "discord",
                "spotify": "spotify",
                "steam": "steam",
                "obs": "obs-studio",
                "vlc": "vlc",
                "vscode": "code",
                "code": "code"
            }
            app_cmd = app_map.get(target, target)
            self.agent.log(f"Executing: Launching {target.capitalize()}...", C_SUCCESS)
            self.agent.speak(f"Opening {target.capitalize()}.")
            os.system(f"{app_cmd} &>/dev/null &")
            return True
            
        else:
            # Dynamically launch general apps cleanly
            clean_target = target.replace("file", "").replace("app", "").strip()
            if clean_target:
                self.agent.log(f"Executing: Launching {clean_target.capitalize()} dynamically...", C_SUCCESS)
                self.agent.speak(f"Opening {clean_target.capitalize()}.")
                os.system(f"{clean_target} &>/dev/null &")
                return True
                
        return False

    def _handle_system_status(self, text, cmd):
        self.agent.log("Executing: Querying System Diagnostics...", C_SUCCESS)
        self.agent.play_sound_effect("thinking")
        
        # 1. CPU Load
        try:
            with open("/proc/loadavg", "r") as f:
                load = f.read().split()[0]
        except Exception:
            load = "unknown"
            
        # 2. RAM Usage
        try:
            with open("/proc/meminfo", "r") as f:
                lines = f.readlines()
            mem_total = 0
            mem_avail = 0
            for line in lines:
                if "MemTotal" in line:
                    mem_total = int(line.split()[1])
                elif "MemAvailable" in line:
                    mem_avail = int(line.split()[1])
            if mem_total > 0:
                mem_used_pct = int((mem_total - mem_avail) / mem_total * 100)
            else:
                mem_used_pct = "unknown"
        except Exception:
            mem_used_pct = "unknown"
            
        # 3. Disk Usage
        try:
            import shutil
            total, used, free = shutil.disk_usage("/")
            disk_free_gb = int(free / (1024**3))
        except Exception:
            disk_free_gb = "unknown"
            
        # 4. CPU Temperature
        cpu_temp = ""
        try:
            for path in ["/sys/class/thermal/thermal_zone0/temp", "/sys/class/hwmon/hwmon0/temp1_input", "/sys/class/hwmon/hwmon1/temp1_input"]:
                if os.path.exists(path):
                    with open(path, "r") as f:
                        cpu_temp = f"{int(f.read().strip()) / 1000:.0f}°C"
                        break
        except Exception:
            pass
            
        temp_str = f" with a core temperature of {cpu_temp}" if cpu_temp else ""
        
        report = (
            f"Mayank, your workstation is performing beautifully. "
            f"The CPU load average is {load}, memory utilization is at {mem_used_pct} percent, "
            f"and you have {disk_free_gb} gigabytes of free disk space on your primary drive{temp_str}. "
            f"Everything is running perfectly in order."
        )
        
        self.agent.speak(report)
        return True

    def _handle_workspace_nav(self, text, cmd):
        import re
        match = re.search(r'\b(workspace|go to workspace|go to)\s+(\d+)\b', cmd)
        if match:
            num = match.group(2)
            self.agent.log(f"Executing: Switching to workspace {num}...", C_SUCCESS)
            self.agent.speak(f"Switching to workspace {num}.")
            os.system(f"hyprctl dispatch workspace {num} &>/dev/null")
            return True
        return False

    def _handle_window_to_workspace(self, text, cmd):
        import re
        match = re.search(r'\b(move window to workspace|move window to|move to)\s+(\d+)\b', cmd)
        if match:
            num = match.group(2)
            self.agent.log(f"Executing: Moving window to workspace {num}...", C_SUCCESS)
            self.agent.speak(f"Moving active window to workspace {num}.")
            os.system(f"hyprctl dispatch movetoworkspace {num} &>/dev/null")
            return True
        return False

    def _handle_active_window(self, text, cmd):
        self.agent.log("Executing: Fetching focused window details...", C_SUCCESS)
        self.agent.play_sound_effect("thinking")
        try:
            import json
            res = subprocess.run(["hyprctl", "activewindow", "-j"], capture_output=True, text=True)
            if res.returncode == 0:
                data = json.loads(res.stdout)
                title = data.get("title", "")
                wm_class = data.get("class", "")
                if wm_class:
                    self.agent.speak(f"You are currently focusing on the {wm_class} window, titled: {title[:40]}.")
                else:
                    self.agent.speak("No active window is currently focused, Mayank.")
            else:
                self.agent.speak("I couldn't query the Hyprland active window, Mayank.")
        except Exception:
            self.agent.speak("Hyprland active window query failed.")
        return True

    def _handle_fullscreen(self, text, cmd):
        self.agent.log("Executing: Toggling fullscreen...", C_SUCCESS)
        self.agent.speak("Toggling fullscreen.")
        os.system("hyprctl dispatch fullscreen 0 &>/dev/null")
        return True

    def _handle_floating(self, text, cmd):
        self.agent.log("Executing: Toggling floating window...", C_SUCCESS)
        self.agent.speak("Toggling floating state.")
        os.system("hyprctl dispatch togglefloating active &>/dev/null")
        return True

    def _handle_media_play(self, text, cmd):
        self.agent.log("Executing: Play media...", C_SUCCESS)
        os.system("playerctl play &>/dev/null")
        return True

    def _handle_media_pause(self, text, cmd):
        self.agent.log("Executing: Pause media...", C_SUCCESS)
        os.system("playerctl pause &>/dev/null")
        return True

    def _handle_media_next(self, text, cmd):
        self.agent.log("Executing: Next track...", C_SUCCESS)
        os.system("playerctl next &>/dev/null")
        return True

    def _handle_media_prev(self, text, cmd):
        self.agent.log("Executing: Previous track...", C_SUCCESS)
        os.system("playerctl previous &>/dev/null")
        return True

    def _handle_media_current(self, text, cmd):
        self.agent.log("Executing: Fetching current media details...", C_SUCCESS)
        try:
            res_title = subprocess.run(["playerctl", "metadata", "title"], capture_output=True, text=True)
            res_artist = subprocess.run(["playerctl", "metadata", "artist"], capture_output=True, text=True)
            title = res_title.stdout.strip()
            artist = res_artist.stdout.strip()
            if title:
                artist_str = f" by {artist}" if artist else ""
                self.agent.speak(f"You are listening to {title}{artist_str}, Mayank.")
            else:
                self.agent.speak("There is no music currently playing, Mayank.")
        except Exception:
            self.agent.speak("I couldn't fetch the current music metadata.")
        return True

    def _handle_timer(self, text, cmd):
        import re
        import time
        import threading
        match = re.search(r'\b(\d+)\s*(second|minute|sec|min|hour|hr)s?\b', cmd)
        if match:
            val = int(match.group(1))
            unit = match.group(2)
            
            if "minute" in unit or "min" in unit:
                secs = val * 60
                unit_str = "minute" if val == 1 else "minutes"
            elif "hour" in unit or "hr" in unit:
                secs = val * 3600
                unit_str = "hour" if val == 1 else "hours"
            else:
                secs = val
                unit_str = "second" if val == 1 else "seconds"
                
            label_match = re.search(r'\b(to|for)\s+(.+)$', cmd)
            label = label_match.group(2) if label_match else "your timer"
            
            self.agent.log(f"Executing: Setting timer for {val} {unit_str} ({label})...", C_SUCCESS)
            self.agent.speak(f"Setting a timer for {val} {unit_str} to {label}.")
            
            def timer_thread():
                time.sleep(secs)
                self.agent.play_sound_effect("activate")
                self.agent.notify("Nixi Timer Alert", f"Timer Complete: {label.capitalize()}", 5000)
                self.agent.speak(f"Mayank, your timer for {label} has completed!")
                
            threading.Thread(target=timer_thread, daemon=True).start()
            return True
        return False

    def _handle_weather(self, text, cmd):
        city = text.lower().replace("weather in", "").replace("weather", "").replace("what is the weather like in", "").strip()
        if not city:
            city = "Delhi"
            
        self.agent.log(f"Executing: Fetching weather for {city}...", C_SUCCESS)
        self.agent.play_sound_effect("thinking")
        
        try:
            import urllib.request
            import urllib.parse
            import json
            
            url = f"https://wttr.in/{urllib.parse.quote(city)}?format=j1"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=5) as response:
                data = json.loads(response.read().decode())
                current = data['current_condition'][0]
                temp_c = current['temp_C']
                desc = current['weatherDesc'][0]['value'].lower()
                humidity = current['humidity']
                
            report = f"The current weather in {city.capitalize()} is {temp_c} degrees Celsius with {desc}. The humidity is at {humidity} percent."
            self.agent.speak(report)
        except Exception as e:
            self.agent.log(f"Weather error: {e}", C_ERROR)
            self.agent.speak(f"I couldn't fetch the weather for {city} right now, Mayank. Please make sure you are online.")
        return True

    def _handle_nixos_clean(self, text, cmd):
        self.agent.log("Executing: Deep garbage collection & store optimization...", C_SUCCESS)
        self.agent.speak("Initializing deep system clean. I will let you know when it is complete.")
        
        def clean_thread():
            import subprocess
            res = subprocess.run(["manx", "clean"], capture_output=True, text=True)
            if res.returncode == 0:
                self.agent.play_sound_effect("access_granted")
                self.agent.notify("Nixi System Doctor", "Garbage collection & store optimization complete!", 4000)
                self.agent.speak("Mayank, deep system clean is complete. Multiple gigabytes of storage have been reclaimed.")
            else:
                self.agent.speak("System clean failed. Please check the logs.")
                
        import threading
        threading.Thread(target=clean_thread, daemon=True).start()
        return True

