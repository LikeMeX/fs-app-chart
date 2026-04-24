---
title: fs-app-chart Runbook
repo: fs-app-chart
layer: infra
tech: Helm
default_branch: main
updated: 2026-04-24
source_path: docs/runbook.md
---

## Runbook — fs-app-chart Operations

### Bump chart version

1. Edit `Chart.yaml` — increment `version` (chart changes) and/or `appVersion` (application version).
2. Commit and push — semantic-release in the consumer repo will pick up the new submodule pointer.

```yaml
# Chart.yaml
version: 0.2.0      # bump when chart templates/values change
appVersion: '1.5.0' # bump when the deployed app version changes
```

### Release a new chart version

```bash
# Tag the chart repo
git tag v0.2.0
git push origin v0.2.0
```

Consumer repos pin the submodule SHA; update it with:

```bash
# Inside the consumer repo
git submodule update --remote fs-app-chart
git add fs-app-chart
git commit -m "chore: bump fs-app-chart to v0.2.0"
```

### Install / upgrade in a consumer repo

```bash
# Manual install (dev)
helm upgrade --install --atomic --timeout 600s \
  <RELEASE_NAME> \
  fs-app-chart/ \
  -f deploy/values-dev.yaml \
  --namespace dev \
  --create-namespace

# Manual install (production)
helm upgrade --install --atomic --timeout 600s \
  <RELEASE_NAME> \
  fs-app-chart/ \
  -f deploy/values-production.yaml \
  --namespace production \
  --create-namespace
```

The `deploy-to-cluster.yaml` reusable workflow runs this automatically on every merge.

### Values overrides in a consumer repo

Consumer repos provide per-environment values files at `deploy/values-<env>.yaml`. The `<DOCKER_TAG>` placeholder is replaced at deploy time:

```yaml
# deploy/values-dev.yaml
image:
  repository: gcr.io/futureskillstaging/my-service
  tag: <DOCKER_TAG>

replicaCount: 1

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-service.dev.futureskill.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Enable autoscaling

```yaml
# values override
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Reference external secrets (ExternalSecret operator)

```yaml
# values override
external_secret_refs:
  - name: my-service-db-secret
  - name: my-service-api-keys
```

### Lint and dry-run

```bash
helm lint fs-app-chart/ -f deploy/values-dev.yaml
helm upgrade --install --dry-run <RELEASE_NAME> fs-app-chart/ -f deploy/values-dev.yaml --namespace dev
```

### Check a deployed release

```bash
helm list -n dev
helm status <RELEASE_NAME> -n dev
helm get values <RELEASE_NAME> -n dev
```

### Roll back a release

```bash
helm rollback <RELEASE_NAME> 0 -n dev   # 0 = previous revision
helm rollback <RELEASE_NAME> 2 -n dev   # specific revision number
```
