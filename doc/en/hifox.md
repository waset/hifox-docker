# HiFox CLI (`hifox`)

[简体中文](../hifox.md) | English · [← Back to README](../../README.en.md)

## Official Links

- Official Website: https://www.hifox.com

## Container Configuration

- **Status**: Pre-installed in `/usr/local/bin/hifox` (latest upstream release at image build time).
- **Persistent Volume**: `hifox-config` mounted at `/root/.hifox`.
- **Registration Flow**:
  - On the very first container start, the entrypoint checks `/root/.hifox/.computer-connect-complete`.
  - If absent, it registers the node automatically using `INSTALL_TOKEN`:
    ```bash
    hifox computer register --install-token "$INSTALL_TOKEN" --yes --skip-service-restart
    ```
  - Once registered, the marker file and node credentials persist inside the `hifox-config` volume; `INSTALL_TOKEN` is unset from memory and no longer required on subsequent restarts or image upgrades.

## Common Commands

```bash
# Check installed HiFox version
docker exec -it hifox hifox --version

# Follow container and daemon logs
docker logs -f hifox

# Open an interactive shell inside the node container
docker exec -it hifox bash
```
