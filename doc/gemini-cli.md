# Google Gemini CLI (`gemini`)

English | [简体中文](zh-CN/gemini-cli.md) · [← Back to README](../README.md)

## Official Links

- GitHub Repository: https://github.com/google-gemini/gemini-cli
- npm Package: https://www.npmjs.com/package/@google/gemini-cli

## Installation in Container

- **Automatic on startup**: Add `gemini` to `AGENT_CLIS` (e.g. `AGENT_CLIS=gemini`).
- **Manual installation**:
  ```bash
  docker exec -it hifox npm install -g @google/gemini-cli@latest
  ```

## Authentication & Persistence

- **File Storage Mode**: `GEMINI_FORCE_FILE_STORAGE="true"` is exported globally so Gemini CLI bypasses missing OS keyrings and stores OAuth credentials on disk under `/root/.gemini` and `/root/.config/gemini` (persisted via `./data:/root`).
- **Fixed Hostname Requirement**: Gemini CLI's `FileTokenStorage` derives its AES-256-GCM encryption key from `os.hostname()`. Always keep a fixed container hostname (`--hostname hifox-daemon` or `HIFOX_HOSTNAME=hifox-daemon`) so encrypted tokens remain decryptable across container recreations.

## Common Commands

```bash
docker exec -it hifox bash

# Check version
gemini --version

# Launch Gemini CLI and complete Google sign-in or API key setup
gemini
```
