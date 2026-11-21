# hifox-docker

[![Release](https://img.shields.io/github/v/release/waset/hifox-docker?logo=github)](https://github.com/waset/hifox-docker/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/waset/hifox-docker/release.yml?logo=docker&label=build)](https://github.com/waset/hifox-docker/actions/workflows/release.yml)
[![Arch](https://img.shields.io/badge/arch-linux%2Famd64%20%7C%20linux%2Farm64-blue)](#一镜像版本选择)

开箱即用的 **HiFox 容器化节点运行环境**，内置 `hifox`、`Node.js（LTS）`、`git`、`gh`、`python3` 等基础工具，可选集成官方原版 **`farion1231/cc-switch` Web 图形界面**。默认不预装具体 AI Agent CLI，所有按需安装的 CLI 及其登录态均自动持久化。

---

## 一、镜像版本选择

均原生支持 `linux/amd64` 与 `linux/arm64`（Apple Silicon / ARM 服务器）：

| 镜像标签 | 镜像地址 | 适用场景 |
| :--- | :--- | :--- |
| **`latest`** *(推荐)* | `ghcr.io/waset/hifox-docker:latest` | **全功能版**：内置 HiFox + 官方 CC-Switch Web GUI（可通过 `ENABLE_CC_SWITCH=false` 动态关闭 GUI） |
| **`slim`** | `ghcr.io/waset/hifox-docker:slim` | **精简无头版**：仅含 HiFox + 基础命令行环境，不含任何 GUI 依赖，体积更小 |

---

## 二、三步快速部署

无需克隆源码或本地构建，直接拉取镜像即可运行：

### 1. 下载部署配置

```bash
mkdir -p hifox && cd hifox
curl -fsSLO https://raw.githubusercontent.com/waset/hifox-docker/main/docker-compose.yml
curl -fsSLO https://raw.githubusercontent.com/waset/hifox-docker/main/.env.example
cp .env.example .env
```

### 2. 配置 `.env`

编辑 `.env`，填入首次注册所需的 `INSTALL_TOKEN`（注册完成后节点凭证持久保存在卷中，后续重启可留空）：

```dotenv
INSTALL_TOKEN=sit_xxxxxxxxxxxxxxxxxxxx
CC_SWITCH_PORT=3000
CC_SWITCH_VNC_PASSWORD=
AGENT_CLIS=
```

### 3. 启动服务

```bash
docker compose pull
docker compose up -d
```

- **CC-Switch Web 界面**：浏览器打开 `http://localhost:3000`（点击界面内授权链接会自动复制并弹出链接框，粘贴至宿主机浏览器即可完成授权）。

---

## 三、安装与登录 Agent CLI

镜像默认不预装 Agent CLI，安装后的二进制自动持久保存在 `./data/.local/bin` 中，升级镜像不会丢失。

### 方式 1：通过 `.env` 启动时自动安装

修改 `.env` 中的 `AGENT_CLIS`（支持 `claude`、`codex`、`gemini`、`codebuddy`、`agy`、`opencode` 或任意 npm 包名），重启生效：

```dotenv
AGENT_CLIS=claude,codex,gemini
```

```bash
docker compose up -d
```

### 方式 2：进入容器手动安装

```bash
docker exec -it hifox bash

# 按需选择安装
npm install -g @anthropic-ai/claude-code@latest
npm install -g @openai/codex@latest
npm install -g @google/gemini-cli@latest
npm install -g @tencent-ai/codebuddy-code@latest
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

### 各工具登录速查（登录态均自动持久化）

```bash
docker exec -it hifox bash

gh auth login --insecure-storage   # GitHub CLI（自动关联 Git 凭据）
claude login                       # Claude Code
codex login --device-auth          # OpenAI Codex（自动落盘至 auth.json）
gemini                             # Google Gemini CLI（已启用文件存储模式）
codebuddy                          # Tencent CodeBuddy
agy                                # Google Antigravity CLI
```

---

## 四、常用运维命令

```bash
# 查看运行日志
docker compose logs -f

# 拉取最新镜像并无损升级容器（保留所有已装 CLI 与登录态）
docker compose pull && docker compose up -d

# 仅运行后台节点、关闭 CC-Switch Web GUI（修改 .env 中 ENABLE_CC_SWITCH=false 后执行）
docker compose up -d

# 停止服务（切勿加 -v，避免删除节点注册卷和 CC-Switch 数据库卷）
docker compose down

# （开发者可选）基于本地 Dockerfile 构建运行
docker compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
```

---

## 五、环境变量说明

| 变量名 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `INSTALL_TOKEN` | *(空)* | 首次启动注册 HiFox 节点的短期安装令牌 |
| `HIFOX_IMAGE` | `ghcr.io/waset/hifox-docker:latest` | 运行镜像（可改为 `:slim` 或指定固定版本如 `:v0.0.1`） |
| `ENABLE_CC_SWITCH` | `true` | 是否启动内置官方 CC-Switch Web GUI（`false` 时零 GUI 内存占用） |
| `CC_SWITCH_PORT` | `3000` | Web GUI 映射宿主机端口 |
| `CC_SWITCH_VNC_PASSWORD` | *(空)* | Web GUI 访问密码（公网部署强烈建议设置） |
| `AGENT_CLIS` | *(空)* | 启动时按需自动安装的 CLI 列表，逗号分隔 |
| `AGENT_CLIS_UPDATE` | `false` | 每次启动容器时是否强制升级 `AGENT_CLIS` 至最新版 |
| `HIFOX_HOSTNAME` | `hifox-daemon` | 容器固定主机名（请勿随意修改，防止基于主机名加密的 Token 失效） |
| `TZ` | `Asia/Shanghai` | 容器时区 |

---

## 六、数据与登录态持久化结构

```text
.
├── data/                        # 映射至容器 /root（所有运行时安装的 CLI 与登录配置）
│   ├── .local/                  # 按需安装的 Agent CLI 二进制、npm 全局包及 XDG 状态
│   ├── .config/                 # gh 登录配置（hosts.yml）及固定机器指纹（machine-id）
│   ├── .gitconfig               # Git 全局配置与 gh 凭据助手
│   ├── .ssh/                    # SSH 密钥对与 known_hosts
│   ├── .claude/ & .claude.json  # Claude Code 登录态与会话配置
│   ├── .codex/                  # Codex 登录态（auth.json）与配置
│   ├── .gemini/                 # Gemini CLI 与 Antigravity 登录态
│   └── .codebuddy/              # CodeBuddy 配置
├── Volume: hifox-config         # 映射至 /root/.hifox（HiFox 节点注册凭证与运行态）
└── Volume: cc-switch-data       # 映射至 /root/.cc-switch（官方 CC-Switch SQLite 数据库与备份）
```
