# Claude Code Hook Notifications

This is a Claude Code plugin that provides macOS desktop notifications for key events during Claude Code sessions.

## What This Plugin Does

This plugin sends native macOS notifications when:

1. **Claude Code completes a task** - Get notified when Claude finishes processing and stops
2. **Permission is requested** - Get alerted when Claude needs your approval for an operation

This is particularly useful when running long-running tasks or when you're working in another application and want to be notified when Claude needs your attention.

## Architecture

The plugin consists of:

- **TypeScript Source**: `src/notify.ts` - Handles notification delivery and logging
- **Hook Configuration**: `hooks/hooks.json` - Maps Claude Code hook events to notification commands
- **Plugin Manifest**: `.claude-plugin/plugin.json` - Declares the plugin to Claude Code

### How It Works

1. Claude Code triggers hooks at specific lifecycle events (Stop, PermissionRequest)
2. The hook configuration executes `npx tsx src/notify.ts` with the appropriate event type
3. The script receives hook context via stdin (session ID, project path, etc.)
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
- Node.js (for running TypeScript)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) installed via Homebrew:
  ```bash
  brew install terminal-notifier
  ```

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yusufpapurcu/claude-hook-notifications.git
   cd claude-hook-notifications
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Install the plugin to Claude Code:
   ```bash
   npm run plugin:install
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

- `/install-notifications` - Install dependencies and verify the plugin setup

When you run this command in Claude Code, Claude will:
1. Install npm dependencies
2. Verify terminal-notifier is installed
3. Test the notification system

No other manual interaction is required - the plugin integrates seamlessly with Claude Code's hook system.

## Development

### Project Structure

```
.
├── src/
│   └── notify.ts              # Main notification script
├── hooks/
│   └── hooks.json             # Hook configuration for Claude Code
├── commands/
│   └── install-notifications.md  # Installation slash command
├── .claude/
│   └── CLAUDE.md              # This file
├── .claude-plugin/
│   ├── plugin.json            # Plugin manifest
│   └── marketplace.json       # Marketplace configuration
├── package.json               # Node.js dependencies
└── README.md                  # User documentation
```

### Testing

```bash
# Install dependencies
npm install

# Test the notification manually
echo '{"cwd":"/path/to/project"}' | npx tsx src/notify.ts stop
echo '{"cwd":"/path/to/project"}' | npx tsx src/notify.ts permission-request
```

### Code Structure

- `src/notify.ts:1-30` - Imports and constants
- `src/notify.ts:32-50` - Hook context parsing from stdin
- `src/notify.ts:52-80` - macOS notification delivery via terminal-notifier
- `src/notify.ts:82-95` - Event logging to `~/.claude/hook-notifications.log`
- `src/notify.ts:97-130` - Main entry point and event routing

## Working with Claude Code

When Claude Code is working with this codebase, here are some helpful tips:

### Common Tasks

**Testing the plugin:**
```bash
npm install
echo '{"cwd":"'$(pwd)'"}' | npx tsx src/notify.ts stop
```

**Checking logs:**
```bash
tail -f ~/.claude/hook-notifications.log
```

**Modifying hook behavior:**
Edit `hooks/hooks.json` to change which events trigger notifications or add new event types.

## License

MIT
