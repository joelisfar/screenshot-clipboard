#!/bin/bash
echo "Uninstalling screenshot-clipboard..."
launchctl unload ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist 2>/dev/null || true
rm -f ~/bin/copy-newest-screenshot.sh
rm -f ~/Library/LaunchAgents/com.user.screenshot-clipboard.plist
rm -f /tmp/screenshot-copy-last
echo "✓ Uninstalled."
