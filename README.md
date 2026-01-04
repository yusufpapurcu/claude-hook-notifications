# Claude Code Hook Notifications

Get native macOS desktop notifications when Claude Code completes tasks or requests permissions.

## Features

- Desktop notification when Claude Code finishes processing
- Alert when Claude Code needs your permission
- Works seamlessly in the background
- Detailed logging for debugging

## Quick Start

### Prerequisites

- macOS
- [terminal-notifier](https://github.com/julienXX/terminal-notifier): `brew install terminal-notifier`

### Installation

#### Option 1: Download Pre-built Binary (Recommended)

```bash
# Download the latest release for your system from:
# https://github.com/yusufpapurcu/claude-hook-notifications/releases
# - Apple Silicon (M1/M2/M3): claude-hook-notifications-darwin-arm64.tar.gz
# - Intel: claude-hook-notifications-darwin-amd64.tar.gz

# Extract the archive
tar -xzf claude-hook-notifications-darwin-*.tar.gz
cd claude-hook-notifications

# Install to Claude plugins directory
cp -r . ~/.claude/plugins/claude-hook-notifications

# Restart Claude Code to load the plugin
```

#### Option 2: Build from Source

Requires Go 1.23+

```bash
# Clone the repository
git clone https://github.com/yusufpapurcu/claude-hook-notifications.git
cd claude-hook-notifications

# Build and install
make build
make install

# Restart Claude Code to load the plugin
```

That's it! Notifications will now appear automatically when Claude Code completes tasks or requests permissions.

## How It Works

This plugin uses Claude Code's hook system to trigger native macOS notifications at key moments:

- **Stop Hook**: Notifies when Claude finishes processing
- **PermissionRequest Hook**: Alerts when Claude needs your approval

All events are logged to `~/.claude/hook-notifications.log` for your reference.

## Customization

Customize the notification icon by setting an environment variable:

```bash
# Use an app's bundle ID
export CLAUDE_NOTIFICATION_ICON="com.apple.Terminal"

# Or use a custom image
export CLAUDE_NOTIFICATION_ICON="/path/to/icon.png"
```

## Documentation

For detailed documentation, architecture details, and development guide, see [CLAUDE.md](.claude/CLAUDE.md).

## Testing

Test notifications manually:

```bash
# Build the binary
make build

# Test the stop notification
echo '{"cwd":"'$(pwd)'"}' | ./bin/notify stop

# Test the permission request notification
echo '{"cwd":"'$(pwd)'"}' | ./bin/notify permission-request

# Check the logs
tail -f ~/.claude/hook-notifications.log
```

## License

MIT
