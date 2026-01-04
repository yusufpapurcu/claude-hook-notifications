# Install Claude Hook Notifications Binary

You are helping the user install the `claude-hook-notifications` binary for their system.

## Steps to Execute

### 1. Determine Plugin Directory

Check these locations in order and use the first one that exists:
- `$CLAUDE_PLUGIN_ROOT` (if set)
- `~/.claude/plugins/marketplaces/claude-hook-notifications-marketplace/claude-hook-notifications/`
- `~/.claude/plugins/claude-hook-notifications/`

### 2. Check Current Installation Status

Check if the binary already exists:
```bash
ls -lh <plugin-dir>/bin/notify
```

If the binary exists and is executable:
- Inform the user it's already installed
- Test it: `echo '{"cwd":"test"}' | <plugin-dir>/bin/notify stop`
- Show last 5 lines from `~/.claude/hook-notifications.log`
- Skip to step 4

### 3. Run Installation Script

If binary doesn't exist, run the installation script:
```bash
cd <plugin-dir>
./install.sh
```

Show the output to the user.

### 4. Verify Dependencies

Check if `terminal-notifier` is installed:
```bash
which terminal-notifier
```

If not found, tell the user to install it:
```bash
brew install terminal-notifier
```

### 5. Summary

Provide a concise summary:
- ✅ Binary installation status
- ✅ terminal-notifier status
- Next steps if needed (install terminal-notifier, restart Claude Code for fresh installs)

## Important Notes

- Use the Bash tool to run all commands
- Be concise - only show relevant output
- If any step fails, show the error and suggest troubleshooting
