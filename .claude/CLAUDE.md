# Claude Code Hook Notifications

This is a Claude Code plugin that provides macOS desktop notifications for key events during Claude Code sessions.

## What This Plugin Does

This plugin sends native macOS notifications when:

1. **Claude Code completes a task** - Get notified when Claude finishes processing and stops
2. **Permission is requested** - Get alerted when Claude needs your approval for an operation

This is particularly useful when running long-running tasks or when you're working in another application and want to be notified when Claude needs your attention.

## Architecture

The plugin consists of:

- **Binary**: `bin/notify` - A Go binary that handles notification delivery and logging
- **Hook Configuration**: `hooks/hooks.json` - Maps Claude Code hook events to notification commands
- **Plugin Manifest**: `.claude-plugin/plugin.json` - Declares the plugin to Claude Code

### How It Works

1. Claude Code triggers hooks at specific lifecycle events (Stop, PermissionRequest)
2. The hook configuration executes the `notify` binary with the appropriate event type
3. The binary receives hook context via stdin (session ID, project path, etc.)
4. A macOS notification is sent using `terminal-notifier`
5. The event is logged to `~/.claude/hook-notifications.log`

## Technical Details

### Hook Events

The plugin listens to these Claude Code hooks:

- **Stop**: Triggered when Claude completes processing and returns control to the user
- **PermissionRequest**: Triggered when Claude needs user permission to proceed

### Notification Customization

You can customize the notification icon by setting the `CLAUDE_NOTIFICATION_ICON` environment variable:

```bash
# Use an app's icon by bundle ID
export CLAUDE_NOTIFICATION_ICON="com.apple.Terminal"

# Or use a custom image file
export CLAUDE_NOTIFICATION_ICON="/path/to/icon.png"
```

Default icon: Terminal.app (`com.apple.Terminal`)

### Logging

All hook events are logged to `~/.claude/hook-notifications.log` with timestamps for debugging and audit purposes.

Log format:
```
[2026-01-04 15:30:45] Hook: stop Event: Completion received - claude-hook-notifications
[2026-01-04 15:31:12] Hook: permission-request Event: Permission requested - claude-hook-notifications
```

## Prerequisites

- macOS (uses macOS notification system)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) installed via Homebrew:
  ```bash
  brew install terminal-notifier
  ```
- Go 1.23+ (for building the binary)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yusufpapurcu/claude-hook-notifications.git
   cd claude-hook-notifications
   ```

2. Build the notification binary:
   ```bash
   make build
   # Or manually:
   go build -o bin/notify main.go
   ```

3. Install the plugin to Claude Code:
   ```bash
   make install
   # Or manually copy to Claude plugins directory:
   # cp -r . ~/.claude/plugins/claude-hook-notifications
   ```

4. Ensure `terminal-notifier` is installed:
   ```bash
   brew install terminal-notifier
   ```

## Usage

Once installed, the plugin runs automatically in the background. You'll receive notifications when:

- Claude Code finishes processing a task
- Claude Code requests your permission for an operation

### Slash Commands

The plugin provides the following slash command:

- `/install-notifications` - Automatically download and install the notification binary for your system

When you run this command in Claude Code, Claude will:
1. Check if the binary is already installed
2. Run the installation script if needed
3. Verify terminal-notifier is installed
4. Test the binary and show recent notifications

This command is particularly useful for marketplace installations where the binary isn't included in the repository.

No other manual interaction is required - the plugin integrates seamlessly with Claude Code's hook system.

## Development

### Project Structure

```
.
├── main.go                    # Main notification binary
├── install.sh                 # Binary installation script
├── bin/                       # Compiled binaries
│   └── notify                 # The notification executable
├── hooks/
│   └── hooks.json            # Hook configuration for Claude Code
├── slash-commands/
│   └── install-notifications.md  # Installation slash command
├── .claude/
│   └── CLAUDE.md             # This file
└── .claude-plugin/
    ├── plugin.json           # Plugin manifest
    └── marketplace.json      # Marketplace configuration
```

### Building

```bash
# Build the binary
go build -o bin/notify main.go

# Test the notification manually
echo '{"cwd":"/path/to/project"}' | ./bin/notify stop
echo '{"cwd":"/path/to/project"}' | ./bin/notify permission-request
```

### Code Structure

- `main.go:31-70` - Main entry point and event routing
- `main.go:73-90` - Hook context parsing from stdin
- `main.go:92-129` - macOS notification delivery via terminal-notifier
- `main.go:131-162` - Event logging to `~/.claude/hook-notifications.log`

## Working with Claude Code

When Claude Code is working with this codebase, here are some helpful tips:

### Common Tasks

**Testing the plugin:**
```bash
# Build and test
go build -o bin/notify main.go
echo '{"cwd":"'$(pwd)'"}' | ./bin/notify stop
```

**Checking logs:**
```bash
tail -f ~/.claude/hook-notifications.log
```

**Modifying hook behavior:**
Edit `hooks/hooks.json` to change which events trigger notifications or add new event types.

## License

MIT
