#!/usr/bin/env node

import { spawn } from "child_process";
import { appendFile, mkdir, stat } from "fs/promises";
import { homedir } from "os";
import { basename, dirname, join } from "path";

const LOG_FILE_NAME = ".claude/hook-notifications.log";
const NOTIFICATION_TITLE = "Claude Code";
const DEFAULT_APP_ICON = "com.apple.Terminal";

interface HookContext {
  session_id?: string;
  cwd?: string;
  permission_mode?: string;
  hook_event_name?: string;
  tool_name?: string;
}

async function readHookContext(): Promise<HookContext> {
  return new Promise((resolve) => {
    let data = "";

    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });

    process.stdin.on("end", () => {
      if (!data.trim()) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(data));
      } catch {
        console.error("Warning: failed to parse JSON context");
        resolve({});
      }
    });

    // Handle case where stdin is empty/closed immediately
    if (process.stdin.isTTY) {
      resolve({});
    }
  });
}

async function sendNotification(
  title: string,
  message: string
): Promise<void> {
  const args = ["-title", title, "-message", message, "-sound", "default"];

  const customIcon = process.env.CLAUDE_NOTIFICATION_ICON || DEFAULT_APP_ICON;

  try {
    const stats = await stat(customIcon);
    if (stats.isFile()) {
      args.push("-contentImage", customIcon);
      args.push("-sender", "com.apple.Terminal");
    } else {
      args.push("-sender", customIcon);
    }
  } catch {
    // Not a file path, treat as bundle ID
    args.push("-sender", customIcon);
  }

  return new Promise((resolve, reject) => {
    const child = spawn("terminal-notifier", args);

    let stderr = "";
    child.stderr.on("data", (data) => {
      stderr += data;
    });

    child.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`terminal-notifier failed with code ${code}: ${stderr}`));
      } else {
        resolve();
      }
    });

    child.on("error", (err) => {
      reject(new Error(`Failed to spawn terminal-notifier: ${err.message}`));
    });
  });
}

async function logEvent(hookType: string, eventMessage: string): Promise<void> {
  const home = homedir();
  const logPath = join(home, LOG_FILE_NAME);
  const logDir = dirname(logPath);

  await mkdir(logDir, { recursive: true });

  const timestamp = new Date().toISOString().replace("T", " ").slice(0, 19);
  const logEntry = `[${timestamp}] Hook: ${hookType} Event: ${eventMessage}\n`;

  await appendFile(logPath, logEntry, { encoding: "utf8" });
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);

  if (args.length < 1) {
    console.error("Usage: notify <hook-type>");
    process.exit(1);
  }

  const hookType = args[0];

  const context = await readHookContext();

  const projectName = context.cwd ? basename(context.cwd) : "unknown";

  let eventMessage: string;
  switch (hookType) {
    case "stop":
      eventMessage = `Completion received - ${projectName}`;
      break;
    case "permission-request":
      eventMessage = `Permission requested - ${projectName}`;
      break;
    default:
      console.error(`Unknown hook type: ${hookType}`);
      process.exit(1);
  }

  try {
    await sendNotification(NOTIFICATION_TITLE, eventMessage);
  } catch (err) {
    console.error(`Error sending notification: ${err}`);
    process.exit(1);
  }

  try {
    await logEvent(hookType, eventMessage);
  } catch (err) {
    console.error(`Error logging event: ${err}`);
    process.exit(1);
  }
}

main();
