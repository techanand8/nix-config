#!/usr/bin/env python3
import os
import json
import sys
import glob
from http.server import SimpleHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

PORT = 8090
DATA_DIR = os.path.expanduser('~/daily-routine-data')

# Ensure the data directory exists
os.makedirs(DATA_DIR, exist_ok=True)

class TrackerRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Allow cross-origin requests for local development flexibility
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed_url = urlparse(self.path)
        path = parsed_url.path

        if path == '/api/data':
            query = parse_qs(parsed_url.query)
            date_str = query.get('date', [None])[0]
            if not date_str:
                self.send_error_response(400, 'Missing date parameter')
                return

            # Sanitize date string to prevent directory traversal
            date_str = os.path.basename(date_str)
            file_path = os.path.join(DATA_DIR, f"{date_str}.json")

            if os.path.exists(file_path):
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    self.send_json_response(200, data)
                except Exception as e:
                    self.send_error_response(500, f"Error reading file: {str(e)}")
            else:
                # Return standard empty template for new entries
                template = {
                    "date": date_str,
                    "focusScore": 0,
                    "reflectionScore": 0,
                    "tasksCompleted": 0,
                    "tasksTotal": 0,
                    "yesterdayDone": "",
                    "yesterdayImprove": "",
                    "todayDone": "",
                    "todayDoingNow": "",
                    "tomorrowDone": "",
                    "todayImprove": "",
                    "tasks": [],
                    # Habits Correctness
                    "habits": {
                        "water": False,
                        "sleep": False,
                        "exercise": False,
                        "screen": False,
                        "read": False,
                        "revise": False,
                        "meditate": False,
                        "badHabitsAvoided": False
                    },
                    # Routine Waveform tracking (Ideal vs Realized Alignment)
                    "routineAligned": 0,
                    "routineTimeline": [False, False, False, False, False, False],
                    "sleepHours": 8.0,
                    "screenHours": 4.0,
                    # Academic Focus
                    "academicFocus": [],
                    "academicTasks": "",
                    "academicHours": 0,
                    # VLSI section
                    "vlsiType": "dv", # "dv" or "pd" or "none"
                    "vlsiLanguages": [], # ["SystemVerilog", "Verilog", "VHDL", "cocotb", "SystemC", "Python"]
                    "vlsiMethodologies": [], # ["UVM", "OVM", "Formal Verification", "Logic Synthesis", "CTS", "Routing", "STA"]
                    "vlsiTasks": "",
                    "vlsiHours": 0
                }
                self.send_json_response(200, template)

        elif path == '/api/history':
            # Scan files and return chronological history mapping for charts and sidebars
            try:
                files = glob.glob(os.path.join(DATA_DIR, '*.json'))
                history = []
                for f_path in files:
                    with open(f_path, 'r', encoding='utf-8') as f:
                        try:
                            day_data = json.load(f)
                            # Only extract essential properties to keep payload small
                            history.append({
                                "date": day_data.get("date", os.path.basename(f_path).replace('.json', '')),
                                "focusScore": day_data.get("focusScore", 0),
                                "reflectionScore": day_data.get("reflectionScore", 0),
                                "vlsiHours": day_data.get("vlsiHours", 0),
                                "academicHours": day_data.get("academicHours", 0),
                                "routineAligned": day_data.get("routineAligned", 0),
                                "tasksCompleted": day_data.get("tasksCompleted", 0),
                                "tasksTotal": day_data.get("tasksTotal", 0)
                            })
                        except Exception:
                            # Skip corrupted JSON files
                            continue
                # Sort history chronologically by date string
                history.sort(key=lambda x: x['date'])
                self.send_json_response(200, history)
            except Exception as e:
                self.send_error_response(500, f"Error gathering history: {str(e)}")

        else:
            # Fallback to serving standard static files
            super().do_GET()

    def do_POST(self):
        parsed_url = urlparse(self.path)
        path = parsed_url.path

        if path == '/api/save':
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length == 0:
                self.send_error_response(400, 'Missing request body')
                return

            try:
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                date_str = data.get('date')
                if not date_str:
                    self.send_error_response(400, 'Missing date property')
                    return

                # Sanitize date to prevent traversal
                date_str = os.path.basename(date_str)
                file_path = os.path.join(DATA_DIR, f"{date_str}.json")

                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)

                self.send_json_response(200, {"success": True, "message": f"Data saved for {date_str}"})
            except Exception as e:
                self.send_error_response(500, f"Error saving file: {str(e)}")
        else:
            self.send_error_response(404, 'Endpoint not found')

    def send_json_response(self, status, payload):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode('utf-8'))

    def send_error_response(self, status, message):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"error": message}).encode('utf-8'))

    # Override log_message to prevent terminal spamming
    def log_message(self, format, *args):
        pass

def run():
    # Make sure we serve files from the directory of server.py
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, TrackerRequestHandler)
    print(f"🚀 MANX Tracker Engine serving locally at http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping Tracker Engine...")
        sys.exit(0)

if __name__ == '__main__':
    run()
