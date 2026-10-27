# Homelab repo

## Docker images

Every `image:` in a compose file must be a pinned version tag **plus** its digest:

```yaml
image: ghcr.io/koenkk/zigbee2mqtt:2.14.2@sha256:addbfb08fcef2e4477de1535636118241e10d13e898fbe4d9faba8a4d7396311
```

- Never `latest`, never a bare tag, never a bare digest.
- Use the newest stable release tag, and look up the real multi-arch digest for that tag (e.g. `docker buildx imagetools inspect <image>:<tag>` and take the top-level `Digest:`). Never invent a digest.
- Renovate (`renovate.json5`, `config:best-practices`) keeps tag and digest up to date, so it only works if both are present.
