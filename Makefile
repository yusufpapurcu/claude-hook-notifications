.PHONY: build install clean

# Build the notification binary
build:
	@echo "Building notification binary..."
	@mkdir -p bin
	@go build -o bin/notify main.go
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
	@rm -rf bin/notify
	@echo "Clean complete."
