# screenshot-clipboard

Instantly copy macOS screenshots to your clipboard.

## What it does

1. **Sets your screenshot folder to `~/Pictures/Screenshots`**
2. **Automatically copies every new screenshot to your clipboard**

That's it. Take a screenshot, paste it anywhere — instantly.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joelisfar/screenshot-clipboard/main/uninstall.sh | bash
```

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
