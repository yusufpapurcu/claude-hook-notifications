# Install Claude Hook Notifications

You are helping the user install the `claude-hook-notifications` plugin dependencies.

## Steps to Execute

### 1. Determine Plugin Directory

Check these locations in order and use the first one that exists:
- `$CLAUDE_PLUGIN_ROOT` (if set)
- `~/.claude/plugins/marketplaces/claude-hook-notifications-marketplace/claude-hook-notifications/`
- `~/.claude/plugins/claude-hook-notifications/`

### 2. Install Dependencies

Run npm install in the plugin directory:
```bash
cd <plugin-dir>
npm install
```

### 3. Verify Dependencies

Check if `terminal-notifier` is installed:
```bash
which terminal-notifier
```

If not found, tell the user to install it:
```bash
brew install terminal-notifier
```

### 4. Test the Plugin

Test that notifications work:
```bash
cd <plugin-dir>
echo '{"cwd":"test"}' | npx tsx src/notify.ts stop
```

Show last 5 lines from `~/.claude/hook-notifications.log` to confirm it worked.

### 5. Summary

Provide a concise summary:
- ✅ Dependencies installation status
- ✅ terminal-notifier status
- ✅ Test notification status
- Next steps if needed (install terminal-notifier, restart Claude Code)

## Important Notes

- Use the Bash tool to run all commands
- Be concise - only show relevant output
- If any step fails, show the error and suggest troubleshooting
