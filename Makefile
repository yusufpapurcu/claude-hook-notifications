.PHONY: build install clean deps

# Install dependencies
deps:
	@echo "Installing dependencies..."
	@npm install

# Build the notification binary
build: deps
	@echo "Building notification binary..."
	@mkdir -p bin
	@npm run build
	@cp dist/notify.js bin/notify
	@chmod +x bin/notify
	@echo "Built bin/notify"

# Install the plugin to Claude Code plugins directory
install: build
	@echo "Installing plugin to ~/.claude/plugins/claude-hook-notifications..."
	@mkdir -p ~/.claude/plugins/claude-hook-notifications
	@cp -r bin hooks .claude-plugin ~/.claude/plugins/claude-hook-notifications/
	@echo "Plugin installed successfully!"
	@echo "Restart Claude Code to load the plugin."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf bin/notify dist node_modules
	@echo "Clean complete."
