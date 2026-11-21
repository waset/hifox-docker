# OpenAI Codex CLI (`codex`)

English | [简体中文](zh-CN/codex.md) · [← Back to README](../README.md)

## Official Links

- GitHub Repository: https://github.com/openai/codex
- npm Package: https://www.npmjs.com/package/@openai/codex

## Installation in Container

- **Automatic on startup**: Add `codex` to `AGENT_CLIS` (e.g. `AGENT_CLIS=codex`).
- **Manual installation**:
  ```bash
  docker exec -it hifox npm install -g @openai/codex@latest
  ```

## Authentication & Persistence

- `CODEX_HOME="/root/.codex"` is exported globally and persisted via `./data:/root`.
- `bubblewrap` is pre-installed in the base image for Codex sandboxing compatibility.
- On startup, `/root/.codex/config.toml` is automatically initialized with:
  ```toml
  cli_auth_credentials_store = "file"
  ```
  This forces Codex to persist credentials in `/root/.codex/auth.json` rather than failing on a missing desktop OS keyring.

## Common Commands

```bash
docker exec -it hifox bash

# Check version
codex --version

# Authenticate in a headless/container environment via device code flow
codex login --device-auth

# Launch Codex
codex
```
