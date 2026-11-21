# Google Gemini CLI (`gemini`)

[English](../gemini-cli.md) | 简体中文 · [← 返回首页](../../README.zh-CN.md)

## 官方链接

- GitHub 仓库：https://github.com/google-gemini/gemini-cli
- npm 包主页：https://www.npmjs.com/package/@google/gemini-cli

## 容器内安装方式

- **启动自动安装**：在 `AGENT_CLIS` 中加入 `gemini`（如 `AGENT_CLIS=gemini`）。
- **手动安装**：
  ```bash
  docker exec -it hifox npm install -g @google/gemini-cli@latest
  ```

## 登录态与配置持久化

- **强制文件存储**：全局默认设置 `GEMINI_FORCE_FILE_STORAGE="true"`，跳过容器内缺失的桌面 Keyring，将 OAuth 令牌加密落盘至 `/root/.gemini` 与 `/root/.config/gemini`（通过 `./data:/root` 持久化）。
- **主机名绑定机制**：Gemini CLI 的文件令牌存储使用容器 `hostname` 派生解密密钥，因此请保持固定容器主机名（`--hostname hifox-daemon` 或 `HIFOX_HOSTNAME=hifox-daemon`），确保重建容器后已保存的令牌可正常解密。

## 常用命令

```bash
docker exec -it hifox bash

# 查看版本
gemini --version

# 启动并完成登录授权或配置 API Key
gemini
```
