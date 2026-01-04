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

#### Option 1: Via Claude Code Marketplace (Easiest)

```bash
# Install via Claude Code
claude plugin install claude-hook-notifications

# Restart Claude Code to load the plugin, then run:
/install-notifications

# Or manually run the installation script:
cd ~/.claude/plugins/marketplaces/claude-hook-notifications-marketplace/claude-hook-notifications
./install.sh
```

The `/install-notifications` command will automatically download and install the correct binary for your system.

#### Option 2: Download Pre-built Binary

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

#### Option 3: Build from Source

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

## Usage

### Slash Commands

Once installed, you can use this slash command in Claude Code:

- `/install-notifications` - Install or verify the notification binary

Simply type `/install-notifications` in your Claude Code session and Claude will handle the installation automatically.

The plugin works automatically in the background - no manual interaction needed after installation.

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

## Troubleshooting

### Notifications Not Appearing

**1. Check if the binary exists:**
```bash
# For marketplace installation:
ls -la ~/.claude/plugins/marketplaces/claude-hook-notifications-marketplace/claude-hook-notifications/bin/notify

# For manual installation:
ls -la ~/.claude/plugins/claude-hook-notifications/bin/notify
```

If the binary doesn't exist, run the installation script:
```bash
cd [plugin-directory]
./install.sh
```

**2. Verify terminal-notifier is installed:**
```bash
which terminal-notifier
# Should output: /opt/homebrew/bin/terminal-notifier (or similar)

# If not installed:
brew install terminal-notifier
```

**3. Test the binary manually:**
```bash
cd [plugin-directory]
echo '{"cwd":"test"}' | ./bin/notify stop
```

You should see a notification and a log entry in `~/.claude/hook-notifications.log`.

**4. Check the logs:**
```bash
tail -20 ~/.claude/hook-notifications.log
```

**5. Verify Claude Code loaded the plugin:**
```bash
# List installed plugins
claude plugin list
```

### Binary Download Fails

If `install.sh` fails to download the binary:

1. Check your internet connection
2. Verify releases exist at: https://github.com/yusufpapurcu/claude-hook-notifications/releases
3. Manually download the appropriate release for your architecture:
   - Apple Silicon: `claude-hook-notifications-darwin-arm64.tar.gz`
   - Intel: `claude-hook-notifications-darwin-amd64.tar.gz`
4. Extract and place the `notify` binary in the plugin's `bin/` directory

### Wrong Installation Path

The plugin should be installed at:
- **Marketplace:** `~/.claude/plugins/marketplaces/claude-hook-notifications-marketplace/claude-hook-notifications/`
- **Manual:** `~/.claude/plugins/claude-hook-notifications/`

The `${CLAUDE_PLUGIN_ROOT}` variable in hooks automatically resolves to the correct path.

## License

MIT
