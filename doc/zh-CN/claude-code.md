# Claude Code (`claude`)

[English](../claude-code.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- 官方网站：https://claude.ai/code
- 官方文档：https://docs.anthropic.com/en/docs/claude-code

## 容器内安装方式

- **启动自动安装**：在 `AGENT_CLIS` 中加入 `claude`（如 `AGENT_CLIS=claude`）。
- **手动安装**：
  ```bash
  docker exec -it hifox npm install -g @anthropic-ai/claude-code@latest
  ```
  *（通过 `NPM_CONFIG_PREFIX=/root/.local` 自动持久化安装至 `./data/.local`。）*

## 登录态与配置持久化

- 全局默认导出 `CLAUDE_CONFIG_DIR="/root/.claude"`。
- 容器启动时自动将 `/root/.claude.json` 软链至 `/root/.claude/.claude.json`，确保 Claude Code 与 CC-Switch 读写同一份持久化配置。
- 配合固定 `hostname` 与持久化的 `/etc/machine-id`，升级镜像或重建容器后登录态不会失效。

## 常用命令

```bash
docker exec -it hifox bash

# 查看版本
claude --version

# 交互式登录账号
claude login

# 启动 Claude Code
claude
```
