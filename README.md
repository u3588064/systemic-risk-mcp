# systemic-risk MCP deployment

This repository builds a deployable container image for the MCP server from:

- Upstream source: `systemic-risk`
- MCP transport: HTTP/SSE
- Container port: `8000`
- MCP endpoint after deployment: `/sse`
- Health endpoint: `/health`
- API docs: `/docs`

## Image

GitHub Actions publishes:

```text
ghcr.io/haowang2025/systemic-risk-mcp:latest
```

A commit- SHA tag is also published for each build.

## How the image works

The Docker build clones the latest `main` branch of the upstream repository and copies only:

```text
requirements.txt
src/
mcp/
```

The upstream `data/` directory is intentionally not copied into the image. At runtime the MCP server is configured with:

```text
GITHUB_REPO=u2017310234/systemic-risk
GITHUB_BRANCH=main
DATA_DIR=/tmp/systemic-risk-data
```

Because the local data directory is empty, the MCP server falls back to the current data files in the upstream GitHub repository instead of serving a stale snapshot baked into the image.

## GitHub Actions

The workflow builds and pushes the image:

- on changes to this deployment repository's build files;
- manually with `workflow_dispatch`
- once per week to pick up upstream code/dependency changes.

## Azure Container Apps settings

Recommended runtime settings:

```text
Image: ghcr.io/haowang2025/systemic-risk-mcp:latest
Ingress: External
Target port: 8000
CPU: 0.25
Memory: 0.5Gi
Min replicas: 0
Max replicas: 1
```

Recommended environment variables:

```text
MCP_HOST=0.0.0.0
MCP_PORT=8000
DATA_DIR=/tmp/systemic-risk-data
GITHUB_REPO=u2017310234/systemic-risk
GITHUB_BRANCH=main
```

After Azure deployment, use:

```text
https://<container-app-domain>/health
https://<container-app-domain>/docs
https://<container-app-domain>/sse
```

## GHCR visibility

This repository is private, so the first GHCR package may also be private. For the simplest Azure deployment without registry credentials, change the `systemic-risk-mcp` package visibility to **Public** in GitHub Packages after the first successful workflow run. Alternatively, keep it private and configure GHCR credentials in Azure Container Apps.

