#!/usr/bin/env python3
import sys
from core import NixiAgent

def speak(text):
    """Provides a standalone speak function for external CLI triggers (e.g. systemctl stop actions)."""
    agent = NixiAgent()
    agent.speak(text)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: voice_agent.py [enroll | listen]")
        sys.exit(1)
        
    mode = sys.argv[1].lower()
    agent = NixiAgent()
    
    if mode == "enroll":
        agent.enroll()
    elif mode == "listen":
        agent.listen_and_execute()
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)
