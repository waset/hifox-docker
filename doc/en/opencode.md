# OpenCode & Custom npm CLIs (`opencode`, etc.)

[简体中文](../opencode.md) | English · [← Back to README](../../README.en.md)

## Official Links

- OpenCode Website: https://opencode.ai
- OpenCode Repository: https://github.com/sst/opencode

## Installation in Container

- **OpenCode preset**: Add `opencode` to `AGENT_CLIS` (e.g. `AGENT_CLIS=opencode`), or install manually:
  ```bash
  docker exec -it hifox npm install -g opencode-ai@latest
  ```
- **Any custom npm-based Agent CLI**:
  - Pass the npm package name directly in `AGENT_CLIS` (e.g. `AGENT_CLIS=claude,@qwen-code/qwen-code`), or run `npm install -g <package>` inside the container.

## Persistence Mechanism

- `NPM_CONFIG_PREFIX="/root/.local"` and `PATH="/root/.local/bin:..."` are configured globally.
- Every globally installed npm package (`/root/.local/lib/node_modules`), executable (`/root/.local/bin`), XDG directory (`/root/.config`, `/root/.local/share`, `/root/.local/state`), and `~/.<tool>` dot-directory is persisted on the host via `./data:/root` and survives image upgrades.

## Common Commands

```bash
docker exec -it hifox bash

# Launch OpenCode
opencode

# Upgrade all globally installed npm Agent CLIs
npm update -g
```
