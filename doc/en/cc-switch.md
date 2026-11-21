# CC-Switch (`cc-switch`)

[简体中文](../cc-switch.md) | English · [← Back to README](../../README.en.md)

## Official Links

- Official Website: https://ccswitch.io
- GitHub Repository: https://github.com/farion1231/cc-switch

## Container Configuration

- **Status**: Pre-installed on the `:latest` image variant using the official upstream Linux `.deb` release (`amd64` / `arm64`). Omitted on `:slim`.
- **Web GUI Stack**: Served via TigerVNC + Openbox + noVNC on container port `3000` (`http://localhost:3000` by default), with automatic viewport resizing and CJK font support.
- **Runtime Toggle**:
  - `ENABLE_CC_SWITCH=true` (default): Runs the Web GUI supervisor alongside the HiFox daemon and auto-restarts `cc-switch` across database restore/sync relaunches.
  - `ENABLE_CC_SWITCH=false`: Skips starting X11, VNC, websockify, and `cc-switch` completely (zero GUI CPU/RAM overhead).
- **Access Control**: Set `CC_SWITCH_VNC_PASSWORD` to require password authentication when accessing the Web GUI.
- **OAuth Link Helper**: Clicking external authorization links inside CC-Switch copies the URL to the clipboard and pops up a selectable dialog so you can open it in your host browser.
- **Local Failover Proxy**: Because `cc-switch` and `hifox` run inside the same container network namespace, CC-Switch's local failover proxy (`127.0.0.1:15721`) works out of the box for all Agent CLIs.

## Persistence Details

- **Database & Backups**: Stored in the native Linux `ext4` named volume `cc-switch-data` mounted at `/root/.cc-switch` (`cc-switch.db`, `settings.json`, `backups/`, `skills/`), avoiding SQLite lock/mmap corruption on macOS Docker Desktop (VirtioFS).
- **Desktop WebKit State & OAuth**: Persisted under `/root/.local/share/com.ccswitch.desktop` and `/root/.config/com.ccswitch.desktop` via `./data:/root`.

## Common Operations

- **Access Web GUI**: Open `http://localhost:3000` (or your configured `CC_SWITCH_PORT`).
- **WebDAV Sync**: Configure your WebDAV endpoint, username, and app password under **Settings → Cloud Sync** inside the GUI; credentials persist in `cc-switch-data`.
- **Open In-GUI Terminal**: Right-click the desktop background inside the Web GUI if you need an X11 terminal (`lxterminal`).
