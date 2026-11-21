# OpenCode 及自定义 npm CLI (`opencode` 等)

[English](../opencode.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- OpenCode 官网：https://opencode.ai
- OpenCode 仓库：https://github.com/sst/opencode

## 容器内安装方式

- **OpenCode 内置简称**：在 `AGENT_CLIS` 中加入 `opencode`（如 `AGENT_CLIS=opencode`），或手动安装：
  ```bash
  docker exec -it hifox npm install -g opencode-ai@latest
  ```
- **任意其他 npm Agent CLI**：
  - 可直接在 `AGENT_CLIS` 中填写完整的 npm 包名（例如 `AGENT_CLIS=claude,@qwen-code/qwen-code`），或进入容器直接执行 `npm install -g <包名>`。

## 登录态与持久化机制

- 镜像全局配置了 `NPM_CONFIG_PREFIX="/root/.local"` 并将 `/root/.local/bin` 置于 `PATH` 首位。
- 所有运行时安装的全局 npm 模块（`/root/.local/lib/node_modules`）、可执行文件（`/root/.local/bin`）、XDG 目录（`/root/.config`、`/root/.local/share`、`/root/.local/state`）以及任意 `~/.<tool>` 配置目录均通过 `./data:/root` 自动持久化，升级镜像不会丢失。

## 常用命令

```bash
docker exec -it hifox bash

# 启动 OpenCode
opencode

# 一键更新容器内所有已安装的全局 npm CLI
npm update -g
```
