# screenshot-clipboard

Instantly copy macOS screenshots to your clipboard.

When you take a screenshot, it saves to a folder. This tool watches that folder and automatically copies each new screenshot to your clipboard — instantly.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/screenshot-clipboard/main/install.sh | bash
```

Or with a custom screenshot folder:

```bash
SCREENSHOT_DIR=~/Desktop/Screenshots curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/screenshot-clipboard/main/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/screenshot-clipboard/main/uninstall.sh | bash
```

## How it works

- Uses a macOS LaunchAgent with `WatchPaths` to monitor your screenshot folder
- When a new file appears, a small bash script copies it to clipboard
- Images (PNG/JPEG) are copied as image data (paste anywhere)
- Videos and other files are copied as file references (paste in Finder, Slack, etc.)
- No third-party dependencies, no background apps, just native macOS tools

## Requirements

- macOS (tested on Sonoma, should work on Monterey+)
- Screenshots saving to a dedicated folder (default: `~/Pictures/Screenshots`)

## Files installed

- `~/bin/copy-newest-screenshot.sh` - the script
- `~/Library/LaunchAgents/com.user.screenshot-clipboard.plist` - the watcher

## License

MIT
