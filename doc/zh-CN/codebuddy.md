# Tencent CodeBuddy CLI (`codebuddy`)

[English](../codebuddy.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- 官方网站：https://www.codebuddy.cn
- npm 包主页：https://www.npmjs.com/package/@tencent-ai/codebuddy-code

## 容器内安装方式

- **启动自动安装**：在 `AGENT_CLIS` 中加入 `codebuddy`（如 `AGENT_CLIS=codebuddy`）。
- **手动安装**：
  ```bash
  docker exec -it hifox npm install -g @tencent-ai/codebuddy-code@latest
  ```

## 登录态与配置持久化

- CodeBuddy 的运行配置保存在 `/root/.codebuddy`，而账号登录凭证保存在 `/root/.local/share/CodeBuddyExtension/Data/Public/auth`（`XDG_DATA_HOME`）。
- 两个路径均位于 `/root` 下，随 `./data:/root`、固定 `hostname` 及持久化 `/etc/machine-id` 一并自动保留。

## 常用命令

```bash
docker exec -it hifox bash

# 查看版本
codebuddy --version

# 启动 CodeBuddy 并完成登录
codebuddy
```
