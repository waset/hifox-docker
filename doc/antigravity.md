# Google Antigravity CLI (`agy`)

简体中文 | [English](en/antigravity.md) · [← 返回首页](../README.md)

## 官方链接

- 官方网站：https://antigravity.google

## 容器内安装方式

- **启动自动安装**：在 `AGENT_CLIS` 中加入 `agy`（如 `AGENT_CLIS=agy`）。
- **手动安装**：
  ```bash
  docker exec -it hifox bash -c "curl -fsSL https://antigravity.google/cli/install.sh | bash"
  ```
  *（自动安装至 `/root/.local/bin/agy`，通过 `./data:/root` 持久化保留。）*

## 登录态与配置持久化

- Antigravity CLI 将登录令牌（`antigravity-oauth-token`）、会话记录及 MCP 配置保存在 `/root/.gemini/antigravity-cli` 与 `/root/.config` 下（均由 `./data:/root` 持久化）。
- 容器启动时自动从 `/root/.config/machine-id` 恢复 `/etc/machine-id`，确保设备绑定的会话在容器重建后保持有效。

## 常用命令

```bash
docker exec -it hifox bash

# 查看版本
agy --version

# 启动 Antigravity CLI 并完成授权登录
agy
```
