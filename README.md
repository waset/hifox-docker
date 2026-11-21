# hifox-docker

简体中文 | [English](README.en.md)

[![Docker Hub](https://img.shields.io/docker/v/waset/hifox-docker?sort=semver&logo=docker&label=docker%20hub)](https://hub.docker.com/r/waset/hifox-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/waset/hifox-docker?logo=docker)](https://hub.docker.com/r/waset/hifox-docker)
[![GHCR](https://img.shields.io/badge/ghcr.io-fallback-blue?logo=github)](https://github.com/waset/hifox-docker/pkgs/container/hifox-docker)
[![Release](https://img.shields.io/github/v/release/waset/hifox-docker?logo=github)](https://github.com/waset/hifox-docker/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/waset/hifox-docker/release.yml?logo=githubactions&label=build)](https://github.com/waset/hifox-docker/actions/workflows/release.yml)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational)](#镜像版本)

开箱即用的 **HiFox 容器化节点公共运行环境**，可选内置官方原版 CC-Switch Web 图形界面，默认不预装具体 Agent CLI，完整支持按需安装 CLI 及各类工具登录态持久化。

## 镜像版本

- `:latest` — 全功能版，内置 HiFox 节点守护进程、基础命令行工具链及官方 CC-Switch Web GUI（可通过 `ENABLE_CC_SWITCH` 动态开关 GUI）。
- `:slim` — 精简无头版，仅包含 HiFox 节点守护进程与基础命令行环境，不含任何 X11 / WebKit / VNC 依赖。

## 支持的工具与 Agent CLI

点击下方条目查看对应工具的官网链接、本镜像持久化配置及常用命令说明：

- [HiFox CLI (`hifox`)](doc/hifox.md) — 内置节点注册与后台任务执行守护进程
- [CC-Switch (`cc-switch`)](doc/cc-switch.md) — 内置官方可视化供应商、MCP 与 WebDAV 同步管理工具（`:latest` 版本）
- [GitHub CLI & Git (`gh`, `git`, `ssh`)](doc/github-cli.md) — 内置 GitHub CLI、Git 凭据助手联动与 SSH 密钥持久化
- [Claude Code (`claude`)](doc/claude-code.md) — 按需安装（`AGENT_CLIS=claude`）与登录态持久化说明
- [OpenAI Codex (`codex`)](doc/codex.md) — 按需安装（`AGENT_CLIS=codex`）与文件级凭证持久化说明
- [Google Gemini CLI (`gemini`)](doc/gemini-cli.md) — 按需安装（`AGENT_CLIS=gemini`）与绑定主机名的加密文件凭证说明
- [Tencent CodeBuddy (`codebuddy`)](doc/codebuddy.md) — 按需安装（`AGENT_CLIS=codebuddy`）与 XDG 登录态持久化说明
- [Google Antigravity CLI (`agy`)](doc/antigravity.md) — 按需安装（`AGENT_CLIS=agy`）与机器指纹绑定凭证说明
- [OpenCode 及自定义 npm CLI (`opencode` 等)](doc/opencode.md) — 按需安装与 `/root/.local` 全局持久化说明

## 快速启动

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

将 `docker-compose.yml` 与 `.env` 文件放置在同一工作目录下，直接执行：

```bash
docker compose up -d
```

## 环境变量说明

使用 Docker Compose 时，在 `docker-compose.yml` 同级目录放置 `.env` 文件（使用 `docker run` 时通过 `-e` 传入）：

| 变量名 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `INSTALL_TOKEN` | *(空)* | 首次启动注册 HiFox 节点所需的一次性安装令牌 |
| `HIFOX_IMAGE` | *(主源 `:latest`)* | 容器镜像引用（可切换为 `:slim` 无头版，或在网络不通时切换为 GHCR 备用源） |
| `ENABLE_CC_SWITCH` | `true` | 是否启动内置官方 CC-Switch Web GUI（设为 `false` 时不拉起任何 GUI 进程，零额外内存开销） |
| `CC_SWITCH_PORT` | `3000` | CC-Switch Web GUI 映射至宿主机的端口（`http://localhost:3000`） |
| `CC_SWITCH_VNC_PASSWORD` | *(空)* | 可选的 Web GUI 访问密码（公网环境建议配置） |
| `AGENT_CLIS` | *(空)* | 启动时自动安装到 `/root/.local` 的 CLI 列表，逗号分隔（支持 `claude,codex,gemini,codebuddy,agy,opencode` 或任意 npm 包名） |
| `AGENT_CLIS_UPDATE` | `false` | 每次容器启动时是否强制将 `AGENT_CLIS` 升级至最新版（`true` / `false`） |
| `HIFOX_HOSTNAME` | `hifox-daemon` | 容器固定主机名（登录 CLI 后请勿随意更改，避免依赖主机名派生的加密 Token 失效） |
| `TZ` | `Asia/Shanghai` | 容器时区 |

`.env` 文件放置示例（与 `docker-compose.yml` 同目录）：

```dotenv
INSTALL_TOKEN=sit_xxxxxxxxxxxxxxxxxxxx
ENABLE_CC_SWITCH=true
CC_SWITCH_PORT=3000
CC_SWITCH_VNC_PASSWORD=
AGENT_CLIS=
```

## 持久化目录说明

- `./data:/root` — 持久化运行时安装的 Agent CLI（`/root/.local/bin`）、全局 npm 包、`gh` 登录凭证、`.gitconfig`、`.ssh`、`machine-id` 及所有 `~/.<agent>` 登录状态。
- `hifox-config:/root/.hifox` — 原生 Linux 命名卷，保存 HiFox 节点注册凭证与运行状态。
- `cc-switch-data:/root/.cc-switch` — 原生 Linux 命名卷，保存官方 CC-Switch 的 SQLite 数据库与备份。

## 致谢

- [HiFox](https://www.hifox.com) — 面向 AI 编程智能体的协同工作空间与节点编排平台。
- [CC-Switch](https://ccswitch.io)（[GitHub](https://github.com/farion1231/cc-switch)）— 官方跨平台 AI 编程 CLI 配置、供应商与 MCP 管理工具。
