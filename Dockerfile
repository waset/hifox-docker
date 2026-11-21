# syntax=docker/dockerfile:1
FROM debian:stable-slim

ARG WITH_CC_SWITCH=true
ARG CACHEBUST=1

ENV HOME="/root" \
    NPM_CONFIG_PREFIX="/root/.local" \
    CLAUDE_CONFIG_DIR="/root/.claude" \
    CODEX_HOME="/root/.codex" \
    GH_CONFIG_DIR="/root/.config/gh" \
    GEMINI_FORCE_FILE_STORAGE="true" \
    XDG_CONFIG_HOME="/root/.config" \
    XDG_DATA_HOME="/root/.local/share" \
    XDG_STATE_HOME="/root/.local/state" \
    LANG="C.UTF-8" \
    PATH="/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# 1. 基础运行依赖与动态获取的最新 LTS 版 Node.js
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates \
     curl \
     wget \
     bash \
     git \
     openssh-client \
     jq \
     xz-utils \
     unzip \
     ripgrep \
     libatomic1 \
     bubblewrap \
     procps \
     python3 \
  && rm -rf /var/lib/apt/lists/* \
  && DPKG_ARCH="$(dpkg --print-architecture)" \
  && case "$DPKG_ARCH" in amd64) NODE_ARCH=x64 ;; arm64) NODE_ARCH=arm64 ;; *) NODE_ARCH="$DPKG_ARCH" ;; esac \
  && NODE_VERSION="$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)][0].version')" \
  && curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
     | tar -xJ --strip-components=1 -C /usr/local/

# 2. 官方 APT 签名源安装最新版 GitHub CLI (gh)
RUN install -d -m 0755 /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
     -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && chmod 0644 /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' \
     "$(dpkg --print-architecture)" >/etc/apt/sources.list.d/github-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# 3. 安装最新版 HiFox CLI 至 /usr/local/bin（避免挂载 /root 时被遮蔽）
RUN NPM_CONFIG_PREFIX="/usr/local" curl -fsSL https://file-assets.hifox.com/download/install.sh | bash \
  && install -m 0755 "$(readlink -f /root/.local/bin/hifox)" /usr/local/bin/hifox \
  && rm -rf /root/.local /root/.npm /root/.cache /root/.config

# 4. 按需构建官方版 CC-Switch 桌面端 (farion1231/cc-switch latest) 与 Web GUI 环境
#    故意不安装 gnome-keyring，防止 CLI 将登录凭证写入容器临时内存环导致重启丢失
RUN set -eu; \
  if [ "${WITH_CC_SWITCH}" = "true" ]; then \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      tigervnc-standalone-server \
      tigervnc-tools \
      websockify \
      openbox \
      dbus-x11 \
      lxterminal \
      zenity \
      xclip \
      xdg-utils \
      locales \
      fonts-noto-cjk \
      fonts-noto-color-emoji; \
    sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen; \
    locale-gen; \
    novnc_url="$(curl -fsSL https://api.github.com/repos/novnc/noVNC/releases/latest | jq -r '.tarball_url')"; \
    mkdir -p /usr/share/novnc; \
    curl -fsSL "${novnc_url}" | tar -xz --strip-components=1 -C /usr/share/novnc; \
    printf '%s\n' \
      '<!DOCTYPE html><html><head><meta charset="utf-8">' \
      '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote&reconnect=true">' \
      '<title>CC-Switch</title></head><body></body></html>' >/usr/share/novnc/index.html; \
    case "$(dpkg --print-architecture)" in \
      amd64) deb_arch="x86_64" ;; \
      arm64) deb_arch="arm64" ;; \
      *) echo "Unsupported architecture for official cc-switch" >&2; exit 1 ;; \
    esac; \
    deb_url="$(curl -fsSL https://api.github.com/repos/farion1231/cc-switch/releases/latest \
      | jq -r --arg arch "${deb_arch}" '.assets[] | select(.name | test("Linux-" + $arch + "\\.deb$")) | .browser_download_url' \
      | head -n 1)"; \
    if [ -z "${deb_url}" ] || [ "${deb_url}" = "null" ]; then \
      echo "Failed to resolve latest official CC-Switch .deb asset URL" >&2; \
      exit 1; \
    fi; \
    curl -fL "${deb_url}" -o /tmp/cc-switch.deb; \
    apt-get install -y --no-install-recommends /tmp/cc-switch.deb; \
    rm -f /tmp/cc-switch.deb; \
    mkdir -p /etc/xdg/openbox; \
    printf '%s\n' \
      '<?xml version="1.0" encoding="UTF-8"?>' \
      '<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">' \
      '  <desktops><number>1</number></desktops>' \
      '  <applications>' \
      '    <application type="normal"><maximized>yes</maximized><decor>no</decor></application>' \
      '    <application class="Lxterminal"><maximized>no</maximized><decor>yes</decor></application>' \
      '  </applications>' \
      '</openbox_config>' >/etc/xdg/openbox/rc.xml; \
    printf '%s\n' \
      '#!/bin/sh' \
      'target="${1:-}"' \
      'if [ -n "${target}" ]; then' \
      '  printf "%s" "${target}" | xclip -selection clipboard 2>/dev/null || true' \
      '  zenity --entry \' \
      '    --title="打开链接 (已复制到剪贴板)" \' \
      '    --text="请复制以下链接到宿主机浏览器中打开完成授权或访问：" \' \
      '    --entry-text="${target}" \' \
      '    --width=640 >/dev/null 2>&1 &' \
      'fi' \
      'exit 0' >/usr/local/bin/xdg-open; \
    chmod +x /usr/local/bin/xdg-open; \
    rm -rf /var/lib/apt/lists/*; \
  fi

# 5. 登录态 Shell 环境变量导出与内置组件版本清单生成
RUN cat >/etc/profile.d/hifox-env.sh <<'EOF'
export HOME="/root"
export NPM_CONFIG_PREFIX="/root/.local"
export CLAUDE_CONFIG_DIR="/root/.claude"
export CODEX_HOME="/root/.codex"
export GH_CONFIG_DIR="/root/.config/gh"
export GEMINI_FORCE_FILE_STORAGE="true"
export XDG_CONFIG_HOME="/root/.config"
export XDG_DATA_HOME="/root/.local/share"
export XDG_STATE_HOME="/root/.local/state"
case ":${PATH:-}:" in
  *:/root/.local/bin:*) ;;
  *) PATH="/root/.local/bin${PATH:+:$PATH}" ;;
esac
export PATH
EOF
RUN printf '\n[ -f /etc/profile.d/hifox-env.sh ] && . /etc/profile.d/hifox-env.sh\n' >>/etc/bash.bashrc

RUN set -eu; \
  node_ver="$(node --version)"; \
  npm_ver="$(npm --version)"; \
  gh_ver="$(gh --version | head -n 1 | awk '{print $3}')"; \
  hifox_ver="$(hifox --version | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.]+)?' | head -n 1)"; \
  if dpkg-query -W -f='${Version}' cc-switch >/dev/null 2>&1; then \
    cc_ver="$(dpkg-query -W -f='${Version}' cc-switch)"; \
  else \
    cc_ver="-"; \
  fi; \
  jq -n \
    --arg node "${node_ver}" \
    --arg npm "${npm_ver}" \
    --arg gh "${gh_ver}" \
    --arg hifox "${hifox_ver}" \
    --arg cc_switch "${cc_ver}" \
    '{hifox: $hifox, cc_switch: $cc_switch, node: $node, npm: $npm, gh: $gh}' \
    >/etc/hifox-versions.json \
  && cat /etc/hifox-versions.json

# 6. 登录态持久化初始化、按需 Agent CLI 安装器、GUI 守护进程与统一入口脚本
RUN cat >/usr/local/bin/hifox-init-persistence <<'EOF'
#!/bin/sh
set -eu

mkdir -p \
  /root/.cc-switch \
  /root/.claude \
  /root/.codex \
  /root/.gemini \
  /root/.codebuddy \
  /root/.config/gh \
  /root/.local/bin \
  /root/.local/lib/node_modules \
  /root/.local/share \
  /root/.local/state \
  /root/.ssh
chmod 700 /root/.ssh

# 当宿主机空目录首次挂载到 /root 时补齐默认 Shell 配置文件
if [ ! -f /root/.bashrc ] && [ -f /etc/skel/.bashrc ]; then
  cp /etc/skel/.bashrc /root/.bashrc
fi
if [ ! -f /root/.profile ] && [ -f /etc/skel/.profile ]; then
  cp /etc/skel/.profile /root/.profile
fi

# 持久化 /etc/machine-id，确保依赖机器指纹加密的 CLI 登录态在容器重建后不失效
MACHINE_ID_FILE="/root/.config/machine-id"
if [ ! -s "${MACHINE_ID_FILE}" ]; then
  if [ -s /etc/machine-id ]; then
    cp /etc/machine-id "${MACHINE_ID_FILE}"
  else
    cat /proc/sys/kernel/random/uuid | tr -d '-' >"${MACHINE_ID_FILE}"
  fi
fi
cp "${MACHINE_ID_FILE}" /etc/machine-id
if [ -d /var/lib/dbus ]; then
  cp "${MACHINE_ID_FILE}" /var/lib/dbus/machine-id
fi

# 统一 /root/.claude.json 与 /root/.claude/.claude.json 供 Claude Code 和 CC-Switch 共享
if [ ! -f /root/.claude/.claude.json ]; then
  if [ -f /root/.claude.json ] && [ ! -L /root/.claude.json ]; then
    mv /root/.claude.json /root/.claude/.claude.json
  else
    printf '{}\n' >/root/.claude/.claude.json
  fi
fi
ln -sfn /root/.claude/.claude.json /root/.claude.json

# 在持久化的 /root/.gitconfig 中自动关联 GitHub CLI 凭据助手
touch /root/.gitconfig
if ! grep -q 'gh auth git-credential' /root/.gitconfig 2>/dev/null; then
  cat >>/root/.gitconfig <<'GITEOF'
[credential "https://github.com"]
	helper = 
	helper = !/usr/bin/gh auth git-credential
[credential "https://gist.github.com"]
	helper = 
	helper = !/usr/bin/gh auth git-credential
GITEOF
fi

# 强制 Codex CLI 使用文件模式保存 auth.json，避免因无桌面 Keyring 导致掉登录
if [ ! -f /root/.codex/config.toml ]; then
  printf 'cli_auth_credentials_store = "file"\n' >/root/.codex/config.toml
elif ! grep -Eq '^[[:space:]]*cli_auth_credentials_store[[:space:]]*=' /root/.codex/config.toml; then
  tmp_codex="$(mktemp /root/.codex/config.toml.XXXXXX)"
  {
    printf 'cli_auth_credentials_store = "file"\n\n'
    cat /root/.codex/config.toml
  } >"${tmp_codex}"
  chmod 600 "${tmp_codex}"
  mv "${tmp_codex}" /root/.codex/config.toml
fi
EOF

RUN cat >/usr/local/bin/hifox-install-agents <<'EOF'
#!/bin/sh
set -eu

RAW_LIST="${AGENT_CLIS:-}"
if [ -z "${RAW_LIST}" ]; then
  exit 0
fi

FORCE_UPDATE="${AGENT_CLIS_UPDATE:-false}"
NORM_LIST="$(printf '%s' "${RAW_LIST}" | tr ',' ' ')"

need_install() {
  bin_name="$1"
  if [ "${FORCE_UPDATE}" = "true" ] || [ "${FORCE_UPDATE}" = "1" ]; then
    return 0
  fi
  ! command -v "${bin_name}" >/dev/null 2>&1
}

for item in ${NORM_LIST}; do
  case "${item}" in
    claude|claude-code)
      if need_install claude; then
        echo "[agent-init] 正在安装最新版 Claude Code CLI..."
        npm install -g --unsafe-perm --no-audit --no-fund "@anthropic-ai/claude-code@latest" \
          || curl -fsSL https://claude.ai/install.sh | bash
      fi
      ;;
    codex)
      if need_install codex; then
        echo "[agent-init] 正在安装最新版 OpenAI Codex CLI..."
        npm install -g --unsafe-perm --no-audit --no-fund "@openai/codex@latest"
      fi
      ;;
    gemini|gemini-cli)
      if need_install gemini; then
        echo "[agent-init] 正在安装最新版 Google Gemini CLI..."
        npm install -g --unsafe-perm --no-audit --no-fund "@google/gemini-cli@latest"
      fi
      ;;
    codebuddy|codebuddy-code)
      if need_install codebuddy; then
        echo "[agent-init] 正在安装最新版 Tencent CodeBuddy CLI..."
        npm install -g --unsafe-perm --no-audit --no-fund "@tencent-ai/codebuddy-code@latest" \
          || curl -fsSL https://www.codebuddy.cn/cli/install.sh | bash
      fi
      ;;
    agy|antigravity)
      if need_install agy; then
        echo "[agent-init] 正在安装最新版 Google Antigravity CLI..."
        curl -fsSL https://antigravity.google/cli/install.sh | bash
      fi
      ;;
    opencode|opencode-ai)
      if need_install opencode; then
        echo "[agent-init] 正在安装最新版 OpenCode CLI..."
        npm install -g --unsafe-perm --no-audit --no-fund "opencode-ai@latest"
      fi
      ;;
    *)
      echo "[agent-init] 正在安装自定义 npm CLI 包: ${item}..."
      npm install -g --unsafe-perm --no-audit --no-fund "${item}"
      ;;
  esac
done

npm cache clean --force >/dev/null 2>&1 || true
EOF

RUN cat >/usr/local/bin/hifox-start-gui <<'EOF'
#!/bin/sh
set -eu

export LANG="zh_CN.UTF-8"
export LC_ALL="zh_CN.UTF-8"
export DISPLAY=":99"
export WEBKIT_DISABLE_DMABUF_RENDERER="1"
export WEBKIT_DISABLE_COMPOSITING_MODE="1"
export WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS="1"
export LIBGL_ALWAYS_SOFTWARE="1"
export NO_AT_BRIDGE="1"

rm -f /tmp/.X99-lock /tmp/.X11-unix/X99

VNC_PORT=5900
WEB_PORT="${CC_SWITCH_INTERNAL_PORT:-3000}"

if [ -n "${CC_SWITCH_VNC_PASSWORD:-}" ]; then
  mkdir -p /root/.vnc
  printf '%s\n' "${CC_SWITCH_VNC_PASSWORD}" | tigervncpasswd -f >/root/.vnc/passwd
  chmod 600 /root/.vnc/passwd
  Xtigervnc :99 \
    -localhost yes \
    -rfbport "${VNC_PORT}" \
    -geometry 1440x900 \
    -depth 24 \
    -SecurityTypes VncAuth \
    -PasswordFile /root/.vnc/passwd \
    -AlwaysShared &
else
  Xtigervnc :99 \
    -localhost yes \
    -rfbport "${VNC_PORT}" \
    -geometry 1440x900 \
    -depth 24 \
    -SecurityTypes None \
    -AlwaysShared &
fi
VNC_PID=$!

i=0
while [ ! -S /tmp/.X11-unix/X99 ] && [ "$i" -lt 50 ]; do
  sleep 0.1
  i=$((i + 1))
done

eval "$(dbus-launch --sh-syntax)"
openbox &
OPENBOX_PID=$!

websockify --web=/usr/share/novnc "${WEB_PORT}" "127.0.0.1:${VNC_PORT}" &
WEBSOCKIFY_PID=$!

CC_BIN="$(command -v cc-switch || command -v CC-Switch || echo /usr/bin/cc-switch)"
CC_PID=""

cleanup_gui() {
  kill "${CC_PID:-}" "${WEBSOCKIFY_PID:-}" "${OPENBOX_PID:-}" "${DBUS_SESSION_BUS_PID:-}" "${VNC_PID:-}" 2>/dev/null || true
  exit 0
}
trap cleanup_gui INT TERM EXIT

while kill -0 "${VNC_PID}" 2>/dev/null && kill -0 "${WEBSOCKIFY_PID}" 2>/dev/null; do
  "${CC_BIN}" &
  CC_PID=$!
  wait "${CC_PID}" || true
  sleep 1
done
EOF

RUN cat >/usr/local/bin/hifox-entrypoint <<'EOF'
#!/bin/sh
set -eu
umask 077

/usr/local/bin/hifox-init-persistence
/usr/local/bin/hifox-install-agents

CONFIG_DIR="/root/.hifox"
CONNECT_MARKER="${CONFIG_DIR}/.computer-connect-complete"
mkdir -p "${CONFIG_DIR}"
if [ ! -f "${CONNECT_MARKER}" ]; then
  if [ -z "${INSTALL_TOKEN:-}" ]; then
    echo "首次启动容器必须提供 INSTALL_TOKEN 环境变量。" >&2
    exit 1
  fi
  hifox computer register --install-token "${INSTALL_TOKEN}" --yes --skip-service-restart
  touch "${CONNECT_MARKER}"
fi
unset INSTALL_TOKEN

ENABLE_GUI="${ENABLE_CC_SWITCH:-true}"
CC_BIN="$(command -v cc-switch || command -v CC-Switch || true)"

if [ "${ENABLE_GUI}" = "true" ] || [ "${ENABLE_GUI}" = "1" ]; then
  if [ -n "${CC_BIN}" ]; then
    /usr/local/bin/hifox-start-gui &
    GUI_PID=$!

    hifox daemon start --foreground &
    DAEMON_PID=$!

    shutdown_all() {
      kill "${DAEMON_PID:-}" "${GUI_PID:-}" 2>/dev/null || true
      wait "${DAEMON_PID:-}" 2>/dev/null || true
      wait "${GUI_PID:-}" 2>/dev/null || true
      exit 0
    }
    trap shutdown_all INT TERM

    set +e
    wait "${DAEMON_PID}"
    DAEMON_STATUS=$?
    set -e

    kill "${GUI_PID:-}" 2>/dev/null || true
    wait "${GUI_PID:-}" 2>/dev/null || true
    exit "${DAEMON_STATUS}"
  else
    echo "[hifox] 当前为精简镜像（未内置 cc-switch），跳过启动 Web GUI，仅运行守护进程。"
  fi
fi

exec hifox daemon start --foreground
EOF

RUN chmod +x \
  /usr/local/bin/hifox-init-persistence \
  /usr/local/bin/hifox-install-agents \
  /usr/local/bin/hifox-start-gui \
  /usr/local/bin/hifox-entrypoint

CMD ["/usr/local/bin/hifox-entrypoint"]
