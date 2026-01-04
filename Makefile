.PHONY: install clean

# Install the plugin to Claude Code plugins directory
install:
	@echo "Installing plugin to ~/.claude/plugins/claude-hook-notifications..."
	@mkdir -p ~/.claude/plugins/claude-hook-notifications
	@cp -r hooks .claude-plugin src package.json package-lock.json ~/.claude/plugins/claude-hook-notifications/
	@cd ~/.claude/plugins/claude-hook-notifications && npm install --silent
	@echo "Plugin installed successfully!"
	@echo "Restart Claude Code to load the plugin."

# Clean local node_modules
clean:
	@echo "Cleaning..."
	@rm -rf node_modules
	@echo "Clean complete."
