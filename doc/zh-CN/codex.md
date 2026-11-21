# OpenAI Codex CLI (`codex`)

[English](../codex.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- GitHub 仓库：https://github.com/openai/codex
- npm 包主页：https://www.npmjs.com/package/@openai/codex

## 容器内安装方式

- **启动自动安装**：在 `AGENT_CLIS` 中加入 `codex`（如 `AGENT_CLIS=codex`）。
- **手动安装**：
  ```bash
  docker exec -it hifox npm install -g @openai/codex@latest
  ```

## 登录态与配置持久化

- 全局导出 `CODEX_HOME="/root/.codex"`，目录通过 `./data:/root` 持久化。
- 基础镜像已内置 `bubblewrap`，消除 Codex 沙箱依赖告警。
- 容器启动时自动确保 `/root/.codex/config.toml` 顶层包含：
  ```toml
  cli_auth_credentials_store = "file"
  ```
  强制将 OAuth 登录凭证落盘至 `/root/.codex/auth.json`，避免因无桌面 Keyring 导致重启后掉登录。

## 常用命令

```bash
docker exec -it hifox bash

# 查看版本
codex --version

# 在容器内通过设备码方式完成官方账号登录
codex login --device-auth

# 启动 Codex
codex
```
