FROM debian:bookworm-slim

ENV CLAUDE_CONFIG_DIR="/root/.claude" \
    CODEX_HOME="/root/.codex" \
    GH_CONFIG_DIR="/root/.config/gh" \
    PATH="/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG NODE_VERSION=22.19.0
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl bash git jq xz-utils ripgrep libatomic1 \
  && rm -rf /var/lib/apt/lists/* \
  && DPKG_ARCH=$(dpkg --print-architecture) \
  && case "$DPKG_ARCH" in amd64) NODE_ARCH=x64 ;; arm64) NODE_ARCH=arm64 ;; *) NODE_ARCH="$DPKG_ARCH" ;; esac \
  && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
     | tar -xJ --strip-components=1 -C /usr/local/

# GitHub CLI from the upstream signed APT repository.
RUN install -d -m 0755 /etc/apt/keyrings \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
     -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && chmod 0644 /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' \
     "$(dpkg --print-architecture)" >/etc/apt/sources.list.d/github-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# CC-Switch's terminal build; verify the pinned upstream musl release asset.
RUN set -eu; \
  case "$(dpkg --print-architecture)" in \
    amd64) arch=x64; sha=42531873444c8b3b41ac5969a70752550ef4c307438d7ca7ee45bcddf201061c ;; \
    arm64) arch=arm64; sha=d2bd3e792d4ca47786d2971ad5258795737057e1ba5f08cabfdb6b4ee85a0bf6 ;; \
    *) echo 'cc-switch: unsupported architecture' >&2; exit 1 ;; \
  esac; \
  tmp="$(mktemp -d)"; \
  trap 'rm -rf "$tmp"' EXIT; \
  curl -fsSL "https://github.com/SaladDay/cc-switch-cli/releases/download/v5.11.3/cc-switch-cli-linux-$arch-musl.tar.gz" -o "$tmp/cc-switch.tar.gz"; \
  printf '%s  %s\n' "$sha" "$tmp/cc-switch.tar.gz" | sha256sum -c -; \
  tar -xzf "$tmp/cc-switch.tar.gz" -C "$tmp"; \
  install -m 0755 "$tmp/cc-switch" /usr/local/bin/cc-switch

RUN curl -fsSL https://file-assets.hifox.com/download/install.sh | bash \
  && ln -sf /root/.local/bin/hifox /usr/local/bin/hifox

# Official CodeBuddy installer (@tencent-ai/codebuddy-code)
RUN (npm install -g --unsafe-perm --no-audit --no-fund "@tencent-ai/codebuddy-code" || curl -fsSL https://www.codebuddy.cn/cli/install.sh | bash) \
  && if [ -x /root/.local/bin/codebuddy ]; then ln -sf /root/.local/bin/codebuddy /usr/local/bin/codebuddy; fi

# Official Claude Code installer (https://claude.ai/install.sh) with npm fallback
RUN (curl -fsSL https://claude.ai/install.sh | bash || npm install -g --unsafe-perm --no-audit --no-fund "@anthropic-ai/claude-code") \
  && if [ -x /root/.local/bin/claude ]; then ln -sf /root/.local/bin/claude /usr/local/bin/claude; fi

# Official Codex installer (@openai/codex)
RUN npm install -g --unsafe-perm --no-audit --no-fund "@openai/codex"

# Official Gemini CLI installer (@google/gemini-cli)
RUN npm install -g --unsafe-perm --no-audit --no-fund "@google/gemini-cli"

# Official Antigravity CLI installer (https://antigravity.google/cli/install.sh)
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash \
  && if [ -x /root/.local/bin/agy ]; then ln -sf /root/.local/bin/agy /usr/local/bin/agy; fi

RUN npm cache clean --force

RUN printf '%s\n' \
  'case ":${PATH:-}:" in *:/root/.local/bin:*) ;; *) PATH="/root/.local/bin${PATH:+:$PATH}" ;; esac' \
  'export PATH' >/etc/profile.d/hifox-path.sh

RUN hifox --version \
  && codebuddy --version \
  && claude --version \
  && codex --version \
  && gemini --version \
  && agy --version \
  && cc-switch --version \
  && gh --version

RUN cat >/usr/local/bin/hifox-container-entrypoint <<'EOF'
#!/bin/sh
set -eu
umask 077

CONFIG_DIR="/root/.hifox"
CONNECT_MARKER="${CONFIG_DIR}/.computer-connect-complete"
mkdir -p "${CONFIG_DIR}"
if [ ! -f "${CONNECT_MARKER}" ]; then
  if [ -z "${INSTALL_TOKEN:-}" ]; then
    echo "INSTALL_TOKEN is required for the first container start." >&2
    exit 1
  fi
  hifox computer register --install-token "${INSTALL_TOKEN}" --yes --skip-service-restart
  touch "${CONNECT_MARKER}"
fi
unset INSTALL_TOKEN
exec hifox daemon start --foreground
EOF

RUN chmod +x /usr/local/bin/hifox-container-entrypoint
CMD ["/usr/local/bin/hifox-container-entrypoint"]
