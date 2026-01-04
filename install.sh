#!/bin/bash
set -e

# Claude Hook Notifications - Binary Installation Script
# This script downloads the appropriate binary for your system architecture

REPO="yusufpapurcu/claude-hook-notifications"
LATEST_RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"

echo "Installing Claude Hook Notifications binary..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    arm64|aarch64)
        ARCH_NAME="arm64"
        ;;
    x86_64|amd64)
        ARCH_NAME="amd64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        echo "This plugin only supports macOS on ARM64 or AMD64"
        exit 1
        ;;
esac

# Detect OS
OS=$(uname -s)
if [ "$OS" != "Darwin" ]; then
    echo "Error: This plugin only supports macOS"
    exit 1
fi

echo "Detected system: darwin-${ARCH_NAME}"

# Get the latest release tag
echo "Fetching latest release information..."
RELEASE_INFO=$(curl -sL "$LATEST_RELEASE_URL")
TAG=$(echo "$RELEASE_INFO" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

if [ -z "$TAG" ]; then
    echo "Error: Could not determine latest release version"
    echo "Please check https://github.com/${REPO}/releases"
    exit 1
fi

echo "Latest release: $TAG"

# Construct download URL
BINARY_NAME="notify"
ARCHIVE_NAME="claude-hook-notifications-darwin-${ARCH_NAME}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG}/${ARCHIVE_NAME}"

echo "Downloading from: $DOWNLOAD_URL"

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download and extract
cd "$TMP_DIR"
if ! curl -sL "$DOWNLOAD_URL" -o "$ARCHIVE_NAME"; then
    echo "Error: Failed to download binary"
    echo "URL: $DOWNLOAD_URL"
    exit 1
fi

echo "Extracting binary..."
tar -xzf "$ARCHIVE_NAME"

# Find the binary in the extracted archive
# Try multiple possible locations
BINARY_PATH=""
for possible_path in \
    "bin/${BINARY_NAME}" \
    "${BINARY_NAME}" \
    "claude-hook-notifications/bin/${BINARY_NAME}" \
    "*/bin/${BINARY_NAME}"; do

    # Use glob expansion for wildcard patterns
    for expanded_path in $possible_path; do
        if [ -f "$expanded_path" ]; then
            BINARY_PATH="$expanded_path"
            break 2
        fi
    done
done

if [ -z "$BINARY_PATH" ]; then
    echo "Error: Could not find binary '${BINARY_NAME}' in archive"
    echo "Archive contents:"
    find . -type f -name "${BINARY_NAME}" || ls -la
    exit 1
fi

echo "Found binary at: $BINARY_PATH"

# Determine installation directory
# If running from plugin directory, install there
# Otherwise, install to ~/.claude/plugins/claude-hook-notifications
if [ -f "$(dirname "$0")/.claude-plugin/plugin.json" ]; then
    # Running from plugin directory
    INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    # Running standalone - install to default plugin location
    INSTALL_DIR="$HOME/.claude/plugins/claude-hook-notifications"
    mkdir -p "$INSTALL_DIR"
fi

echo "Installing to: $INSTALL_DIR/bin/"
mkdir -p "$INSTALL_DIR/bin"
cp "$BINARY_PATH" "$INSTALL_DIR/bin/${BINARY_NAME}"
chmod +x "$INSTALL_DIR/bin/${BINARY_NAME}"

echo "✓ Binary installed successfully to: $INSTALL_DIR/bin/${BINARY_NAME}"
echo ""
echo "Testing binary..."
if "$INSTALL_DIR/bin/${BINARY_NAME}" --version 2>/dev/null || echo '{"cwd":"test"}' | "$INSTALL_DIR/bin/${BINARY_NAME}" stop 2>&1 | grep -q "terminal-notifier"; then
    echo "✓ Binary is working"
else
    echo "Warning: Binary test had unexpected output (this may be normal)"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Note: Make sure terminal-notifier is installed:"
echo "  brew install terminal-notifier"
echo ""
echo "Restart Claude Code to activate the plugin."
