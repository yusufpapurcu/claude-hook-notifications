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

# Fallback version if API rate limit is hit
FALLBACK_VERSION="v1.0.0"

# Get the latest release tag with rate limit handling
echo "Fetching latest release information..."
RELEASE_RESPONSE=$(curl -sL -w "\n%{http_code}" "$LATEST_RELEASE_URL")
RELEASE_HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
RELEASE_INFO=$(echo "$RELEASE_RESPONSE" | sed '$d')

TAG=""
if [ "$RELEASE_HTTP_CODE" -eq 200 ]; then
    TAG=$(echo "$RELEASE_INFO" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
fi

if [ -z "$TAG" ]; then
    if [ "$RELEASE_HTTP_CODE" -eq 403 ]; then
        echo "Warning: GitHub API rate limit reached. Using fallback version: $FALLBACK_VERSION"
        TAG="$FALLBACK_VERSION"
    elif [ "$RELEASE_HTTP_CODE" -eq 404 ]; then
        echo "Error: Repository or releases not found"
        echo "Please check https://github.com/${REPO}/releases"
        exit 1
    else
        echo "Warning: Could not fetch latest release (HTTP $RELEASE_HTTP_CODE). Using fallback version: $FALLBACK_VERSION"
        TAG="$FALLBACK_VERSION"
    fi
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

# Download and extract with proper error handling
cd "$TMP_DIR"
HTTP_CODE=$(curl -sL -w "%{http_code}" "$DOWNLOAD_URL" -o "$ARCHIVE_NAME")
if [ "$HTTP_CODE" -ne 200 ]; then
    echo "Error: Failed to download binary (HTTP $HTTP_CODE)"
    case "$HTTP_CODE" in
        404)
            echo "The release archive was not found. Please check if the release exists."
            ;;
        403)
            echo "Access forbidden. You may have hit GitHub's rate limit."
            ;;
        000)
            echo "Network error. Please check your internet connection."
            ;;
        *)
            echo "Unexpected HTTP error occurred."
            ;;
    esac
    echo "URL: $DOWNLOAD_URL"
    exit 1
fi

# Verify checksum if available
CHECKSUM_FILE="checksums.txt"
CHECKSUM_URL="https://github.com/${REPO}/releases/download/${TAG}/${CHECKSUM_FILE}"
echo "Verifying checksum..."
CHECKSUM_HTTP_CODE=$(curl -sL -w "%{http_code}" "$CHECKSUM_URL" -o "$CHECKSUM_FILE")
if [ "$CHECKSUM_HTTP_CODE" -eq 200 ]; then
    # Extract expected checksum for our archive
    EXPECTED_CHECKSUM=$(grep "${ARCHIVE_NAME}" "$CHECKSUM_FILE" | awk '{print $1}')
    if [ -n "$EXPECTED_CHECKSUM" ]; then
        ACTUAL_CHECKSUM=$(shasum -a 256 "$ARCHIVE_NAME" | awk '{print $1}')
        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            echo "Error: Checksum verification failed!"
            echo "Expected: $EXPECTED_CHECKSUM"
            echo "Actual:   $ACTUAL_CHECKSUM"
            echo "The downloaded file may be corrupted or tampered with."
            exit 1
        fi
        echo "✓ Checksum verified"
    else
        echo "Warning: No checksum found for ${ARCHIVE_NAME} in checksums file"
    fi
else
    echo "Warning: Checksum file not available (HTTP $CHECKSUM_HTTP_CODE). Skipping verification."
    echo "Consider publishing checksums with releases for enhanced security."
fi

echo "Extracting binary..."
tar -xzf "$ARCHIVE_NAME"

# Find the binary in the extracted archive using find for safety
# This avoids shell injection vulnerabilities from malicious archive contents
BINARY_PATH=$(find . -type f -name "${BINARY_NAME}" -print -quit 2>/dev/null)

# If not found by name, check specific known locations
if [ -z "$BINARY_PATH" ]; then
    for possible_path in "bin/${BINARY_NAME}" "${BINARY_NAME}" "claude-hook-notifications/bin/${BINARY_NAME}"; do
        if [ -f "$possible_path" ]; then
            BINARY_PATH="$possible_path"
            break
        fi
    done
fi

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
