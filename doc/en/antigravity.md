# Google Antigravity CLI (`agy`)

[简体中文](../antigravity.md) | English · [← Back to README](../../README.en.md)

## Official Links

- Official Website: https://antigravity.google

## Installation in Container

- **Automatic on startup**: Add `agy` to `AGENT_CLIS` (e.g. `AGENT_CLIS=agy`).
- **Manual installation**:
  ```bash
  docker exec -it hifox bash -c "curl -fsSL https://antigravity.google/cli/install.sh | bash"
  ```
  *(Installs the `agy` binary into `/root/.local/bin/agy`, persisted via `./data:/root`.)*

## Authentication & Persistence

- Antigravity CLI persists its OAuth token (`antigravity-oauth-token`), conversation state, and MCP configs under `/root/.gemini/antigravity-cli` and `/root/.config` (all covered by `./data:/root`).
- `/etc/machine-id` is persisted across container recreations via `/root/.config/machine-id` so device-associated sessions remain valid.

## Common Commands

```bash
docker exec -it hifox bash

# Check version
agy --version

# Launch Antigravity CLI and authenticate
agy
```
