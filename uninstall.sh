#!/bin/bash
echo "Uninstalling screenshot-clipboard..."
launchctl unload ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist 2>/dev/null || true
rm -f ~/bin/copy-newest-screenshot.sh
rm -f ~/bin/screenshot-clipboard
rm -f ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist
rm -f /tmp/screenshot-copy-last
rm -f /tmp/screenshot-clipboard-resized.png

# Restore screenshot settings the installer changed. Each is only restored
# if it still has the value the installer set, so later changes you made
# yourself are left alone.
PREFS_DOMAIN="com.apple.screencapture"
ORIGINALS="$HOME/.config/screenshot-clipboard/original-settings"
if [ -f "$ORIGINALS" ]; then
    restored=0
    while IFS=$'\037' read -r key type original installed; do
        [ -n "$key" ] || continue
        current=$(defaults read "$PREFS_DOMAIN" "$key" 2>/dev/null) || continue
        [ "$current" = "$installed" ] || continue
        case "$type" in
            unset)   defaults delete "$PREFS_DOMAIN" "$key" ;;
            string)  defaults write "$PREFS_DOMAIN" "$key" -string "$original" ;;
            boolean) [ "$original" = 1 ] && v=true || v=false
                     defaults write "$PREFS_DOMAIN" "$key" -bool "$v" ;;
            integer) defaults write "$PREFS_DOMAIN" "$key" -int "$original" ;;
            float)   defaults write "$PREFS_DOMAIN" "$key" -float "$original" ;;
            *)       continue ;;
        esac
        restored=1
    done < "$ORIGINALS"
    rm -f "$ORIGINALS"
    if [ "$restored" = 1 ]; then
        killall SystemUIServer ScreenshotControls screencaptureui 2>/dev/null || true
        echo "→ Restored your original screenshot settings"
    fi
fi

rm -f ~/.config/screenshot-clipboard/half-size
rmdir ~/.config/screenshot-clipboard 2>/dev/null || true
echo "✓ Uninstalled."
