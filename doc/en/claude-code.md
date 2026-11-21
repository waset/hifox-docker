# Claude Code (`claude`)

[简体中文](../claude-code.md) | English · [← Back to README](../../README.en.md)

## Official Links

- Official Website: https://claude.ai/code
- Documentation: https://docs.anthropic.com/en/docs/claude-code

## Installation in Container

- **Automatic on startup**: Add `claude` to `AGENT_CLIS` (e.g. `AGENT_CLIS=claude`).
- **Manual installation**:
  ```bash
  docker exec -it hifox npm install -g @anthropic-ai/claude-code@latest
  ```
  *(Installed persistently into `/root/.local` via `NPM_CONFIG_PREFIX=/root/.local`.)*

## Authentication & Persistence

- `CLAUDE_CONFIG_DIR="/root/.claude"` is exported globally across all interactive and login shells.
- `/root/.claude.json` is automatically symlinked to `/root/.claude/.claude.json` so both Claude Code and CC-Switch read and write the exact same persisted state inside `./data/.claude/`.
- Fixed container `hostname` and persistent `/etc/machine-id` (`/root/.config/machine-id`) keep OAuth sessions valid across container recreations.

## Common Commands

```bash
docker exec -it hifox bash

# Check version
claude --version

# Sign in interactively
claude login

# Launch Claude Code
claude
```
