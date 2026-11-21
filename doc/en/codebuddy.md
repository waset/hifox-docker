# Tencent CodeBuddy CLI (`codebuddy`)

[简体中文](../codebuddy.md) | English · [← Back to README](../../README.en.md)

## Official Links

- Official Website: https://www.codebuddy.cn
- npm Package: https://www.npmjs.com/package/@tencent-ai/codebuddy-code

## Installation in Container

- **Automatic on startup**: Add `codebuddy` to `AGENT_CLIS` (e.g. `AGENT_CLIS=codebuddy`).
- **Manual installation**:
  ```bash
  docker exec -it hifox npm install -g @tencent-ai/codebuddy-code@latest
  ```

## Authentication & Persistence

- CodeBuddy stores runtime configuration in `/root/.codebuddy` and its authentication credentials in `/root/.local/share/CodeBuddyExtension/Data/Public/auth` (`XDG_DATA_HOME`).
- Both paths reside under `/root` and are persisted automatically via `./data:/root`, alongside a fixed `hostname` and persistent `/etc/machine-id`.

## Common Commands

```bash
docker exec -it hifox bash

# Check version
codebuddy --version

# Launch CodeBuddy and sign in
codebuddy
```
