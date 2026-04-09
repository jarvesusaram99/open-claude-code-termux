#!/bin/bash

# OpenClaude Mobile Assistant - Hardware Control Toolkit
# Use this script to abstract complex Termux API interactions.

VERSION="1.0.0"

# Colors
CYN='\033[1;36m'
MAG='\033[1;35m'
YLW='\033[1;33m'
RED='\033[1;31m'
GRN='\033[1;32m'
R='\033[0m'
DIM='\033[2m'

# Auto-approve all actions (God-Mode)
require_permission() {
    return 0
}

# Privilege Escalation Wrapper (Requires Shizuku, ADB, or Root)
run_privileged() {
  export RISH_APPLICATION_ID="com.termux"
  if command -v rish &>/dev/null; then rish -c "$@"
  elif command -v adb &>/dev/null && adb get-state 1>/dev/null 2>&1; then adb shell "$@"
  elif command -v su &>/dev/null; then su -c "$@"
  else 
    echo -e "${RED}❌ Error: Shizuku, ADB, or Root is required for this command.${R}" >&2
    exit 1
  fi
}

case "$1" in
    "status")
        echo -e "${CYN}--- System Status ---${R}"
        echo "Battery:"
        termux-battery-status | grep -E 'percentage|status'
        echo "WiFi:"
        termux-wifi-connectioninfo | grep -E 'ssid|supplicant_state'
        echo "Location:"
        termux-location -p network -r last | grep -E 'latitude|longitude'
        ;;
    
    "notify")
        require_permission "Send notification: $2"
        termux-notification -t "AI Assistant" -c "$2" --priority high
        echo "Notification sent."
        ;;
        
    "camera_snap")
        require_permission "Take a photo"
        out_file="${2:-photo.jpg}"
        echo "Taking photo to $out_file..."
        termux-camera-photo -c 0 "$out_file"
        echo "Photo saved: $out_file"
        ;;
        
    "vibrate")
        require_permission "Vibrate phone"
        termux-vibrate -d ${2:-500}
        echo "Vibrated for ${2:-500}ms."
        ;;
        
    "speak")
        require_permission "Use Text-to-Speech: $2"
        termux-tts-speak "$2"
        echo "Speech executed."
        ;;
        
    "wifi_toggle")
        require_permission "Change WiFi State to: $2"
        termux-wifi-enable "$2"
        echo "WiFi toggled."
        ;;
        
    "sms")
        require_permission "Send SMS to $2"
        termux-sms-send -n "$2" "$3"
        echo "SMS sent."
        ;;

    # ── UI Navigation (Shizuku Required) ──

    "screenshot")
        require_permission "Take a Screen Capture"
        outfile="${2:-/sdcard/screenshot.png}"
        run_privileged "screencap -p '$outfile'"
        echo "Screenshot saved to $outfile"
        ;;

    "ui_dump")
        require_permission "Read Screen UI Elements"
        DUMP_FILE="$HOME/storage/shared/window_dump.xml"
        # Step 1: Dump UI via Shizuku
        run_privileged "uiautomator dump /sdcard/window_dump.xml" 2>&1
        # Step 2: Small delay for file write
        sleep 1
        # Step 3: Parse with Node (using storage/shared which maps to /sdcard)
        if [ -f "$DUMP_FILE" ]; then
            node -e "
const fs = require('fs');
const xml = fs.readFileSync('$DUMP_FILE', 'utf8');
const re = /(text|content-desc)=\"([^\"]+)\"[^>]*bounds=\"(\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\])\"/g;
let m;
while ((m = re.exec(xml)) !== null) {
  if (m[2].trim()) console.log(m[3] + ' ' + m[2]);
}
"
        else
            echo "DEBUG: Dump file not found at $DUMP_FILE"
            echo "DEBUG: Checking /sdcard directly via rish..."
            run_privileged "cat /sdcard/window_dump.xml" > /tmp/ui_dump.xml 2>/dev/null
            if [ -s /tmp/ui_dump.xml ]; then
                node -e "
const fs = require('fs');
const xml = fs.readFileSync('/tmp/ui_dump.xml', 'utf8');
const re = /(text|content-desc)=\"([^\"]+)\"[^>]*bounds=\"(\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\])\"/g;
let m;
while ((m = re.exec(xml)) !== null) {
  if (m[2].trim()) console.log(m[3] + ' ' + m[2]);
}
"
            else
                echo "❌ Could not read UI dump. Is the screen on?"
            fi
        fi
        ;;

    "tap")
        require_permission "Tap Screen at $2, $3"
        run_privileged "input tap $2 $3"
        echo "Tapped coordinates $2, $3"
        ;;

    "swipe")
        require_permission "Swipe Screen"
        run_privileged "input swipe $2 $3 $4 $5 ${6:-500}"
        echo "Swiped."
        ;;

    "text")
        require_permission "Type Text: $2"
        run_privileged "input text '$2'"
        echo "Typed text."
        ;;

    "key")
        require_permission "Press Key Code $2"
        run_privileged "input keyevent $2"
        echo "Pressed key $2."
        ;;

    "open_app")
        require_permission "Open App: $2"
        run_privileged "monkey -p $2 -c android.intent.category.LAUNCHER 1" 2>/dev/null
        echo "Launched $2."
        ;;

    *)
        echo "Usage: bash mobile_tools.sh [command] [args...]"
        echo "Sensors/API: status, notify, camera_snap, vibrate, speak, wifi_toggle, sms"
        echo "UI Nav & System: screenshot, ui_dump, tap, swipe, text, key, open_app"
        ;;
esac
