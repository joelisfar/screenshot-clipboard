#!/bin/bash
# Instant screenshot-to-clipboard for macOS
# https://github.com/joelisfar/screenshot-clipboard
#
# Install: curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/install.sh | bash

set -e

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"

echo "Installing screenshot-clipboard..."
echo ""

# Create Screenshots folder if it doesn't exist
if [ ! -d "$SCREENSHOT_DIR" ]; then
    echo "Creating $SCREENSHOT_DIR..."
    mkdir -p "$SCREENSHOT_DIR"
fi

# Check current screenshot location
CURRENT_LOCATION=$(defaults read com.apple.screencapture location 2>/dev/null || echo "$HOME/Desktop")

if [ "$CURRENT_LOCATION" != "$SCREENSHOT_DIR" ]; then
    echo "Configuring macOS to save screenshots to $SCREENSHOT_DIR..."
    defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
    echo "  (was: $CURRENT_LOCATION)"
fi

# Create bin directory
mkdir -p ~/bin

# Create the script
cat > ~/bin/copy-newest-screenshot.sh << 'SCRIPT'
#!/bin/bash
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
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

case "${NEWEST##*.}" in
    png)
        osascript -e "set the clipboard to (read (POSIX file \"$NEWEST\") as «class PNGf»)"
        ;;
    jpg|jpeg)
        osascript -e "set the clipboard to (read (POSIX file \"$NEWEST\") as JPEG picture)"
        ;;
    *)
        osascript -e "tell app \"Finder\" to set the clipboard to (POSIX file \"$NEWEST\" as alias)"
        ;;
esac
SCRIPT

chmod +x ~/bin/copy-newest-screenshot.sh

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

echo ""
echo "✓ Installed!"
echo "  Screenshots save to: $SCREENSHOT_DIR"
echo "  Auto-copied to clipboard: Yes"
echo ""
echo "To uninstall: curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/uninstall.sh | bash"
