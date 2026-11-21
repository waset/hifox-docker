# GitHub CLI & Git (`gh`, `git`, `ssh`)

[简体中文](../github-cli.md) | English · [← Back to README](../../README.en.md)

## Official Links

- GitHub CLI Website: https://cli.github.com
- Git Website: https://git-scm.com

## Container Configuration & Persistence

- **Status**: `gh`, `git`, and `openssh-client` (`ssh`) are pre-installed in both `:latest` and `:slim` images.
- **Persistent Paths** (all stored inside `./data:/root`):
  - `/root/.config/gh` (`GH_CONFIG_DIR`) — Stores `hosts.yml` and `config.yml`.
  - `/root/.local/state/gh` (`XDG_STATE_HOME`) — Stores `device-id` and token refresh state.
  - `/root/.gitconfig` — Automatically pre-configured on startup with `gh auth git-credential` for `github.com` and `gist.github.com`.
  - `/root/.ssh` — Persists SSH private/public keys and `known_hosts` with `0700` permissions.
- **Keyring Behavior**: No ephemeral `gnome-keyring` daemon is installed, ensuring `gh` writes tokens reliably to `/root/.config/gh/hosts.yml`.

## Common Commands

```bash
# Enter the container
docker exec -it hifox bash

# Authenticate GitHub CLI and persist token to hosts.yml
gh auth login --insecure-storage

# Verify authentication status
gh auth status

# Configure global Git author identity (persisted in /root/.gitconfig)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
