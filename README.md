# Codex Guard

A Claude Code plugin that uses OpenAI Codex to evaluate bash command safety before execution.

## How It Works

When Claude Code requests permission to run a bash command, this plugin:

1. Intercepts the `PermissionRequest` hook
2. Sends the command to Codex for safety evaluation
3. Auto-allows if Codex says "SAFE"
4. Delegates to user if Codex says "UNSAFE" (prints a warning to stderr and lets you decide)

## Requirements

- [OpenAI Codex CLI](https://github.com/openai/codex) installed and authenticated
- `jq` for JSON processing
- `timeout` command (install via `brew install coreutils` on macOS)

```bash
npm i -g @openai/codex
codex login
```

## Installation

```bash
claude /plugins install github:taichimaeda/codex-guard
```

Or test locally:

```bash
claude --plugin-dir /path/to/codex-guard
```

## Configuration

The hook has a 60-second timeout. Adjust in `hooks/hooks.json` if needed.

## Testing

Test the hook script directly:

```bash
echo '{"tool_input": {"command": "rm -rf /"}}' | ./scripts/codex-guard.sh
# stderr → Codex flagged this as unsafe: UNSAFE: ...
# (no stdout, delegates decision to user)

echo '{"tool_input": {"command": "git status"}}' | ./scripts/codex-guard.sh
# → {"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}
```

## License

MIT
