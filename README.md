# hifox-docker

English | [简体中文](README.zh-CN.md)

[![Docker Hub](https://img.shields.io/docker/v/waset/hifox-docker?sort=semver&logo=docker&label=docker%20hub)](https://hub.docker.com/r/waset/hifox-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/waset/hifox-docker?logo=docker)](https://hub.docker.com/r/waset/hifox-docker)
[![GHCR](https://img.shields.io/badge/ghcr.io-fallback-blue?logo=github)](https://github.com/waset/hifox-docker/pkgs/container/hifox-docker)
[![Release](https://img.shields.io/github/v/release/waset/hifox-docker?logo=github)](https://github.com/waset/hifox-docker/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/waset/hifox-docker/release.yml?logo=githubactions&label=build)](https://github.com/waset/hifox-docker/actions/workflows/release.yml)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational)](#image-variants)

Containerized public runtime environment for HiFox nodes, featuring an optional built-in official CC-Switch Web GUI and full login persistence for on-demand AI coding CLIs.

## Image Variants

- `:latest` — Full image containing the HiFox node daemon, base CLI toolchain, and the official CC-Switch Web GUI (GUI can be dynamically toggled via `ENABLE_CC_SWITCH`).
- `:slim` — Headless image containing only the HiFox node daemon and base CLI toolchain without any X11, WebKit, or VNC dependencies.

## Supported Tools & Agent CLIs

Click each item below to view official websites, container configuration, authentication persistence details, and common commands:

- [HiFox CLI (`hifox`)](doc/hifox.md) — Built-in node registration and background task daemon
- [CC-Switch (`cc-switch`)](doc/cc-switch.md) — Built-in official visual provider, MCP, and WebDAV sync manager (`:latest` variant)
- [GitHub CLI & Git (`gh`, `git`, `ssh`)](doc/github-cli.md) — Built-in GitHub CLI, Git credential helper integration, and SSH key persistence
- [Claude Code (`claude`)](doc/claude-code.md) — On-demand installation (`AGENT_CLIS=claude`) and OAuth/config persistence
- [OpenAI Codex (`codex`)](doc/codex.md) — On-demand installation (`AGENT_CLIS=codex`) and file-backed auth persistence
- [Google Gemini CLI (`gemini`)](doc/gemini-cli.md) — On-demand installation (`AGENT_CLIS=gemini`) and hostname-bound file token persistence
- [Tencent CodeBuddy (`codebuddy`)](doc/codebuddy.md) — On-demand installation (`AGENT_CLIS=codebuddy`) and XDG auth persistence
- [Google Antigravity CLI (`agy`)](doc/antigravity.md) — On-demand installation (`AGENT_CLIS=agy`) and machine-bound OAuth persistence
- [OpenCode & Custom npm CLIs (`opencode`, etc.)](doc/opencode.md) — On-demand installation and persistent `/root/.local` global prefix

## Quick Start

### Docker Run

```bash
docker run -d \
  --name hifox \
  --hostname hifox-daemon \
  --shm-size 1g \
  --restart unless-stopped \
  -p 3000:3000 \
  -e INSTALL_TOKEN="your_install_token" \
  -e ENABLE_CC_SWITCH="true" \
  -e CC_SWITCH_VNC_PASSWORD="" \
  -e AGENT_CLIS="" \
  -e TZ="Asia/Shanghai" \
  -v "$(pwd)/data:/root" \
  -v hifox-config:/root/.hifox \
  -v cc-switch-data:/root/.cc-switch \
  <image>:latest
```

### Docker Compose

Place `docker-compose.yml` and a `.env` file in the same working directory, then run:

```bash
docker compose up -d
```

## Environment Variables

When using Docker Compose, place the following variables in `.env` alongside `docker-compose.yml` (or pass them via `-e` in `docker run`):

| Variable | Default | Description |
| :--- | :--- | :--- |
| `INSTALL_TOKEN` | *(empty)* | One-time token required on first startup to register the HiFox node |
| `HIFOX_IMAGE` | *(primary `:latest`)* | Container image reference (switch to `:slim` for headless or GHCR image as fallback) |
| `ENABLE_CC_SWITCH` | `true` | Start the built-in CC-Switch Web GUI (`false` disables all GUI processes with zero memory overhead) |
| `CC_SWITCH_PORT` | `3000` | Host port mapped to the CC-Switch Web GUI (`http://localhost:3000`) |
| `CC_SWITCH_VNC_PASSWORD` | *(empty)* | Optional VNC password protecting the CC-Switch Web GUI |
| `AGENT_CLIS` | *(empty)* | Comma-separated Agent CLIs installed into `/root/.local` on startup (`claude,codex,gemini,codebuddy,agy,opencode` or npm package names) |
| `AGENT_CLIS_UPDATE` | `false` | Force update CLIs listed in `AGENT_CLIS` on every container start (`true` / `false`) |
| `HIFOX_HOSTNAME` | `hifox-daemon` | Fixed container hostname preserving hostname-salted encrypted CLI tokens across recreations |
| `TZ` | `Asia/Shanghai` | Container timezone |

Example `.env` placement (`./.env` next to `./docker-compose.yml`):

```dotenv
INSTALL_TOKEN=sit_xxxxxxxxxxxxxxxxxxxx
ENABLE_CC_SWITCH=true
CC_SWITCH_PORT=3000
CC_SWITCH_VNC_PASSWORD=
AGENT_CLIS=
```

## Persistence Layout

- `./data:/root` — Persists runtime-installed Agent CLIs (`/root/.local/bin`), global npm packages, `gh` credentials, `.gitconfig`, `.ssh`, `machine-id`, and all `~/.<agent>` login states.
- `hifox-config:/root/.hifox` — Named Linux volume storing HiFox node registration state.
- `cc-switch-data:/root/.cc-switch` — Named Linux volume storing the CC-Switch SQLite database and backups.

## Acknowledgements

- [HiFox](https://www.hifox.com) — Collaborative workspace and node orchestration platform for AI coding agents.
- [CC-Switch](https://ccswitch.io) ([Source](https://github.com/farion1231/cc-switch)) — Official cross-platform configuration, provider, and MCP manager for AI coding CLIs.
