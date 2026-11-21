# CC-Switch (`cc-switch`)

简体中文 | [English](en/cc-switch.md) · [← 返回首页](../README.md)

## 官方链接

- 官方网站：https://ccswitch.io
- GitHub 仓库：https://github.com/farion1231/cc-switch

## 容器配置说明

- **内置状态**：`:latest` 全功能镜像内置上游官方最新 Linux `.deb` 桌面版（支持 `amd64` / `arm64`）；`:slim` 镜像不包含该组件。
- **Web GUI 访问**：通过 TigerVNC + Openbox + noVNC 暴露于容器 `3000` 端口（默认访问 `http://localhost:3000`），支持跟随浏览器窗口自动调整分辨率及完整中文显示。
- **运行期动态开关**：
  - `ENABLE_CC_SWITCH=true`（默认）：后台自动拉起 Web GUI，并在数据库恢复/同步重启时自动守护重连。
  - `ENABLE_CC_SWITCH=false`：完全不启动 X11、VNC、noVNC 与 `cc-switch` 进程，零额外内存和 CPU 开销。
- **访问密码**：配置 `CC_SWITCH_VNC_PASSWORD` 可为 Web 界面启用 VNC 密码保护。
- **外部授权链接复制**：在界面内点击外部登录或文档链接时，会自动写入剪贴板并弹出可复制对话框，便于粘贴到宿主机浏览器完成授权。
- **本地故障转移代理**：由于与 `hifox` 运行于同一容器内，开启 CC-Switch 本地代理（`127.0.0.1:15721`）后各 Agent CLI 可直接连通。

## 登录态与数据持久化

- **数据库与备份**：挂载于原生 Linux `ext4` 命名卷 `cc-switch-data:/root/.cc-switch`（保存 `cc-switch.db`、`settings.json`、`backups/`、`skills/`），彻底避免 macOS Docker Desktop（VirtioFS）下的 SQLite 文件锁损坏问题。
- **WebKit 状态与账号登录态**：通过 `./data:/root` 持久化保存在 `/root/.local/share/com.ccswitch.desktop` 与 `/root/.config/com.ccswitch.desktop`。

## 常用操作

- **打开管理界面**：浏览器访问 `http://localhost:3000`（或自定义的 `CC_SWITCH_PORT`）。
- **WebDAV 多端同步**：在界面 **设置 → 云同步** 中填入 WebDAV 地址与应用密码即可同步供应商、MCP 与 Skills 配置。
