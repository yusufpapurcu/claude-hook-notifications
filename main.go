package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

const (
	logFileName       = ".claude/hook-notifications.log"
	notificationTitle = "Claude Code"
	// Use Terminal.app icon as default - you can change this to any app bundle ID
	// Examples: com.apple.Terminal, com.apple.finder, com.github.atom
	defaultAppIcon = "com.apple.Terminal"
)

// HookContext represents the JSON context passed to hooks via stdin
type HookContext struct {
	SessionID      string `json:"session_id"`
	CWD            string `json:"cwd"`
	PermissionMode string `json:"permission_mode"`
	HookEventName  string `json:"hook_event_name"`
	ToolName       string `json:"tool_name,omitempty"`
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: notify <hook-type>")
	}

	hookType := os.Args[1]

	// Read hook context from stdin
	context, err := readHookContext()
	if err != nil {
		log.Printf("Warning: failed to read hook context: %v", err)
	}

	// Extract project name from cwd
	projectName := "unknown"
	if context.CWD != "" {
		projectName = filepath.Base(context.CWD)
	}

	// Determine the event message based on hook type
	var eventMessage string
	switch hookType {
	case "stop":
		eventMessage = fmt.Sprintf("Completion received - %s", projectName)
	case "permission-request":
		eventMessage = fmt.Sprintf("Permission requested - %s", projectName)
	default:
		log.Fatalf("Unknown hook type: %s", hookType)
	}

	// Send macOS notification
	if err := sendNotification(notificationTitle, eventMessage); err != nil {
		log.Printf("Error sending notification: %v", err)
		os.Exit(1)
	}

	// Log the event
	if err := logEvent(hookType, eventMessage); err != nil {
		log.Printf("Error logging event: %v", err)
		os.Exit(1)
	}
}

// readHookContext reads and parses the JSON context from stdin
func readHookContext() (*HookContext, error) {
	data, err := io.ReadAll(os.Stdin)
	if err != nil {
		return nil, fmt.Errorf("failed to read stdin: %w", err)
	}

	// If stdin is empty, return empty context
	if len(data) == 0 {
		return &HookContext{}, nil
	}

	var context HookContext
	if err := json.Unmarshal(data, &context); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	return &context, nil
}

// sendNotification sends a macOS notification using terminal-notifier
func sendNotification(title, message string) error {
	args := []string{
		"-title", title,
		"-message", message,
		"-sound", "default",
	}

	// Support custom icon via environment variable
	// Set CLAUDE_NOTIFICATION_ICON to either:
	// - An app bundle ID (e.g., "com.apple.Terminal")
	// - A path to an image file (will auto-detect)
	customIcon := os.Getenv("CLAUDE_NOTIFICATION_ICON")
	if customIcon == "" {
		customIcon = defaultAppIcon
	}

	// Check if it's a file path or bundle ID
	if _, err := os.Stat(customIcon); err == nil {
		// It's a file path - use as content image
		args = append(args, "-contentImage", customIcon)
		// Also set sender to make notification appear
		args = append(args, "-sender", "com.apple.Terminal")
	} else {
		// It's a bundle ID - use as sender to show that app's icon
		args = append(args, "-sender", customIcon)
	}

	cmd := exec.Command("terminal-notifier", args...)

	// Capture stderr for debugging
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("terminal-notifier failed: %w, output: %s", err, string(output))
	}

	return nil
}

// logEvent appends an event to the log file
func logEvent(hookType, eventMessage string) error {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %w", err)
	}

	logPath := filepath.Join(homeDir, logFileName)

	// Ensure the .claude directory exists
	logDir := filepath.Dir(logPath)
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return fmt.Errorf("failed to create log directory: %w", err)
	}

	// Open log file in append mode
	file, err := os.OpenFile(logPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to open log file: %w", err)
	}
	defer file.Close()

	// Write log entry
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	logEntry := fmt.Sprintf("[%s] Hook: %s Event: %s\n", timestamp, hookType, eventMessage)

	if _, err := file.WriteString(logEntry); err != nil {
		return fmt.Errorf("failed to write log entry: %w", err)
	}

	return nil
}
