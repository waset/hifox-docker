# GitHub CLI & Git (`gh`, `git`, `ssh`)

[English](../github-cli.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- GitHub CLI 官网：https://cli.github.com
- Git 官网：https://git-scm.com

## 容器配置与登录态持久化

- **内置状态**：`gh`、`git` 与 `openssh-client`（`ssh`）在 `:latest` 和 `:slim` 镜像中均已预装。
- **持久化路径**（均通过 `./data:/root` 自动落盘）：
  - `/root/.config/gh`（`GH_CONFIG_DIR`）— 保存登录凭证 `hosts.yml` 与 `config.yml`。
  - `/root/.local/state/gh`（`XDG_STATE_HOME`）— 保存 `device-id` 与令牌刷新锁。
  - `/root/.gitconfig` — 容器启动时自动写入 `gh auth git-credential` 凭据助手，登录 `gh` 后即可直接免密拉取/推送 HTTPS 仓库。
  - `/root/.ssh` — 自动维护 `0700` 权限，持久化 SSH 密钥对与 `known_hosts`。
- **防丢失机制**：镜像不安装内存态 `gnome-keyring`，确保令牌直接落盘至 `hosts.yml`，容器重建不掉线。

## 常用命令

```bash
# 进入容器
docker exec -it hifox bash

# 登录 GitHub CLI 并持久化保存令牌
gh auth login --insecure-storage

# 检查登录状态
gh auth status

# 配置 Git 全局提交身份（持久保存在 /root/.gitconfig）
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
