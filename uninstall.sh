#!/bin/bash
echo "Uninstalling screenshot-clipboard..."
launchctl unload ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist 2>/dev/null || true
rm -f ~/bin/copy-newest-screenshot.sh
rm -f ~/bin/screenshot-clipboard
rm -f ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist
rm -f /tmp/screenshot-copy-last
rm -f /tmp/screenshot-clipboard-resized.png
rm -f ~/.config/screenshot-clipboard/half-size
rmdir ~/.config/screenshot-clipboard 2>/dev/null || true
echo "✓ Uninstalled."
