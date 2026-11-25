#!/bin/bash
# Instant screenshot-to-clipboard for macOS
# https://github.com/joelisfar/screenshot-clipboard
#
# Install: curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/install.sh | bash

set -e

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

echo "Installing screenshot-clipboard..."
echo ""

# Create Screenshots folder
mkdir -p "$SCREENSHOT_DIR"

# Change a screenshot setting, remembering its original value so the
# uninstaller can put it back. Only settings we actually change are
# recorded, and a setting is only recorded once (so re-running the
# installer to update never overwrites the true original).
#   set_pref <key> <string|bool> <value>
PREFS_DOMAIN="com.apple.screencapture"
ORIGINALS="$HOME/.config/screenshot-clipboard/original-settings"
set_pref() {
    local key="$1" type="$2" value="$3" want="$3" current orig_type
    [ "$type" = bool ] && { [ "$value" = true ] && want=1 || want=0; }

    if current=$(defaults read "$PREFS_DOMAIN" "$key" 2>/dev/null); then
        [ "$current" = "$want" ] && return 0    # already set; nothing to change
        orig_type=$(defaults read-type "$PREFS_DOMAIN" "$key" | awk '{print $3}')
    else
        current="" orig_type="unset"
    fi

    mkdir -p "$(dirname "$ORIGINALS")"
    # Fields: key, original type, original value, value we set. Separated by
    # the ASCII unit separator (\037), since tabs would collapse empty fields.
    if ! cut -d $'\037' -f1 "$ORIGINALS" 2>/dev/null | grep -qxF "$key"; then
        printf '%s\037%s\037%s\037%s\n' "$key" "$orig_type" "$current" "$want" >> "$ORIGINALS"
    fi
    defaults write "$PREFS_DOMAIN" "$key" "-$type" "$value"
}

# Set macOS screenshot location
echo "→ Screenshots will save to: $SCREENSHOT_DIR"
set_pref location string "$SCREENSHOT_DIR"
# Newer macOS (confirmed on 27) reads separate keys for screenshots and recordings
set_pref location-screenshot string "$SCREENSHOT_DIR"
set_pref location-screenrecording string "$SCREENSHOT_DIR"

# Disable the floating thumbnail. While it's showing, macOS holds the file
# back (~5s) before writing it to disk, which delays the clipboard copy.
echo "→ Disabling floating screenshot thumbnail"
set_pref show-thumbnail bool false

# Restart the screenshot services so the new settings take effect now.
# Newer macOS caches these settings in the Screenshot helpers too, not
# just SystemUIServer. They relaunch on the next screenshot.
killall SystemUIServer ScreenshotControls screencaptureui 2>/dev/null || true

# Create bin directory
mkdir -p ~/bin

# Create the script
cat > ~/bin/copy-newest-screenshot.sh << 'SCRIPT'
#!/bin/bash
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
LAST_FILE="/tmp/screenshot-copy-last"

sleep 0.3

NEWEST=$(ls -t "$SCREENSHOT_DIR"/* 2>/dev/null | head -1)

if [ -z "$NEWEST" ] || [ ! -f "$NEWEST" ]; then
    exit 0
fi

NEWEST_ID="${NEWEST}:$(stat -f %m "$NEWEST")"
if [ -f "$LAST_FILE" ] && [ "$(cat "$LAST_FILE")" = "$NEWEST_ID" ]; then
    exit 0
fi

echo "$NEWEST_ID" > "$LAST_FILE"

COPY_FILE="$NEWEST"

if [ -f "$HOME/.config/screenshot-clipboard/half-size" ]; then
    case "${NEWEST##*.}" in
        png|jpg|jpeg)
            WIDTH=$(sips -g pixelWidth "$NEWEST" | tail -1 | awk '{print $2}')
            HALF=$(( WIDTH / 2 ))
            RESIZED="/tmp/screenshot-clipboard-resized.png"
            sips --resampleWidth "$HALF" "$NEWEST" --out "$RESIZED" >/dev/null 2>&1
            COPY_FILE="$RESIZED"
            ;;
    esac
fi

case "${COPY_FILE##*.}" in
    png)
        osascript -e "set the clipboard to (read (POSIX file \"$COPY_FILE\") as «class PNGf»)"
        ;;
    jpg|jpeg)
        osascript -e "set the clipboard to (read (POSIX file \"$COPY_FILE\") as JPEG picture)"
        ;;
    *)
        osascript -e "tell app \"Finder\" to set the clipboard to (POSIX file \"$COPY_FILE\" as alias)"
        ;;
esac
SCRIPT

chmod +x ~/bin/copy-newest-screenshot.sh

# Create CLI
cat > ~/bin/screenshot-clipboard << 'CLI'
#!/bin/bash
CONFIG_DIR="$HOME/.config/screenshot-clipboard"
FLAG="$CONFIG_DIR/half-size"
REPO_URL="https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/install.sh"

show_help() {
    cat <<EOF
screenshot-clipboard — instant screenshot-to-clipboard for macOS

Usage:
  screenshot-clipboard            Open settings
  screenshot-clipboard update     Update to latest version
  screenshot-clipboard --help     Show this help

Settings:
  Half-size mode    Downscale retina screenshots 50% before copying
                    to clipboard. Saves ~75% of tokens in AI tools.
                    Original files are never modified.
EOF
}

draw_settings() {
    clear
    local state="OFF"
    [ "$half_size" = 1 ] && state="ON"
    cat <<EOF

  screenshot-clipboard settings

  $([ "$half_size" = 1 ] && printf '[x]' || printf '[ ]') Half-size mode: $state

      Downscale retina screenshots 50% before
      copying to clipboard. Saves ~75% of tokens
      in AI coding tools.

  [h] Toggle half-size
  [Enter] Save & exit
  [q] Quit without saving

EOF
}

run_settings() {
    half_size=0
    [ -f "$FLAG" ] && half_size=1
    local original=$half_size

    draw_settings

    while true; do
        IFS= read -rsn1 key
        case "$key" in
            h|H)
                half_size=$(( 1 - half_size ))
                draw_settings
                ;;
            "")  # Enter
                mkdir -p "$CONFIG_DIR"
                if [ "$half_size" = 1 ]; then
                    touch "$FLAG"
                else
                    rm -f "$FLAG"
                fi
                clear
                if [ "$half_size" != "$original" ]; then
                    local state="full-size"
                    [ "$half_size" = 1 ] && state="half-size"
                    echo "Saved. Mode: $state"
                else
                    echo "No changes."
                fi
                return
                ;;
            q|Q)
                clear
                echo "No changes."
                return
                ;;
        esac
    done
}

case "${1:-}" in
    update)
        echo "Updating screenshot-clipboard..."
        curl -fsSL "$REPO_URL" | bash
        ;;
    --help|-h)
        show_help
        ;;
    *)
        run_settings
        ;;
esac
CLI

chmod +x ~/bin/screenshot-clipboard

# Create LaunchAgent
mkdir -p ~/Library/LaunchAgents

cat > ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.screenshot-clipboard</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/bin/copy-newest-screenshot.sh</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>$SCREENSHOT_DIR</string>
    </array>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
PLIST

# Load it
launchctl unload ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist

# Add ~/bin to PATH if not already there
SHELL_RC="$HOME/.zshrc"
case "$(basename "$SHELL")" in
    bash) SHELL_RC="$HOME/.bashrc" ;;
esac
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
    echo "→ Added ~/bin to PATH in $(basename "$SHELL_RC") (restart your terminal or run: source $SHELL_RC)"
fi

echo "→ Screenshots will auto-copy to clipboard"
echo ""
echo "✓ Done! Take a screenshot and paste it anywhere."
