# HiFox CLI (`hifox`)

[English](../hifox.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- 官方网站：https://www.hifox.com

## 容器配置说明

- **内置状态**：已预装于 `/usr/local/bin/hifox`（构建镜像时自动拉取上游最新版）。
- **持久化卷**：命名卷 `hifox-config` 挂载于 `/root/.hifox`。
- **自动注册流程**：
  - 容器首次启动时，入口脚本会检测 `/root/.hifox/.computer-connect-complete`。
  - 若尚未注册，自动使用环境变量 `INSTALL_TOKEN` 完成节点注册：
    ```bash
    hifox computer register --install-token "$INSTALL_TOKEN" --yes --skip-service-restart
    ```
  - 注册完成后凭证持久保存在 `hifox-config` 卷中，内存中随即清除 `INSTALL_TOKEN`，后续重启或升级镜像无需再次填写。

## 常用命令

```bash
# 查看 HiFox 版本
docker exec -it hifox hifox --version

# 查看守护进程实时日志
docker logs -f hifox

# 进入容器交互式终端
docker exec -it hifox bash
```
