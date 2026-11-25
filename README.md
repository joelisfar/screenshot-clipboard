# screenshot-clipboard

Instantly copy macOS screenshots to your clipboard.

## What it does

1. **Sets your screenshot folder to `~/Pictures/Screenshots`**
2. **Turns off the floating thumbnail** (it delays the file being saved by ~5 seconds)
3. **Automatically copies every new screenshot to your clipboard**

That's it. Take a screenshot, paste it anywhere — instantly.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/uninstall.sh | bash
```

## Settings

Run `screenshot-clipboard` to open the interactive settings screen:

```
screenshot-clipboard            # Open settings
screenshot-clipboard update     # Update to latest version
screenshot-clipboard --help     # Show help
```

### Half-size mode

Retina Macs capture screenshots at 2x resolution. When pasting into AI coding tools (like Claude Code), those extra pixels become base64 tokens that add up across conversation turns. A 1x screenshot is ~75% fewer tokens with negligible quality loss for UI validation.

Toggle it on in the settings screen. When enabled, screenshots are downscaled 50% via `sips` before copying to clipboard. The original file in `~/Pictures/Screenshots` is never modified.

## How it works

- Configures macOS to save screenshots to `~/Pictures/Screenshots`
- A LaunchAgent watches that folder for new files
- When a file appears, it's copied to your clipboard:
  - Images (PNG/JPEG) → paste as image anywhere
  - Videos/other files → paste as file in Finder, Slack, etc.

No apps running in your menu bar. No third-party dependencies. Just native macOS tools.

## Requirements

- macOS (tested on Sonoma, should work on Monterey+)

## License

MIT
