---
title: FutureSkill App Helm Chart
repo: fs-app-chart
layer: infra
tech: Helm
default_branch: main
updated: 2026-04-24
source_path: /
---

## fs-app-chart — FutureSkill Application Helm Chart

A generic Helm chart (`my-app`) used by all FutureSkill backend and frontend services to deploy containerised workloads onto GKE.

**Canonical overview:** [architecture.md](https://github.com/LikeMeX/fs-infrastructure/blob/main/docs/architecture.md)

## Tech stack

| Tool | Version |
| --- | --- |
| Helm API | `v2` |
| Chart version | `0.1.0` |
| App version | `0.1.0` |
| Target runtime | Kubernetes / GKE (`asia-southeast1`) |

## Prerequisites

- `helm` >= 3.10
- `kubectl` configured against the target GKE cluster
- Docker image pushed to a container registry accessible from the cluster

## What the chart provides

| Template | Purpose |
| --- | --- |
| `deployment.yaml` | Main workload — supports env injection, external secrets, configmap mount |
| `service.yaml` | ClusterIP service (port 80 → container 3000) |
| `ingress.yaml` | Optional ingress (networking.k8s.io/v1) |
| `hpa.yaml` | HorizontalPodAutoscaler (CPU + memory) |
| `configmap.yaml` | Per-release ConfigMap for environment config |
| `secret.yaml` | Per-release Secret for sensitive values |
| `serviceaccount.yaml` | Optional Kubernetes ServiceAccount |

## Usage — install in a consumer repo

Consumer repos check this chart in as a Git submodule at `fs-app-chart/` and reference it directly in the deploy step. See `docs/runbook.md` for the full workflow.

### Minimal install

```bash
helm upgrade --install --atomic --timeout 600s \
  my-service \
  fs-app-chart/ \
  --namespace dev \
  --create-namespace \
  --set image.repository=gcr.io/futureskillstaging/my-service \
  --set image.tag=1.2.3
```

### With a values override file

```bash
helm upgrade --install --atomic --timeout 600s \
  my-service \
  fs-app-chart/ \
  -f deploy/values-dev.yaml \
  --namespace dev \
  --create-namespace
```

See `docs/env.md` for a full reference of all supported `values.yaml` keys.

## Environment pointer

- Default values: `values.yaml`
- Full values schema: `docs/env.md`

## Ownership

Infrastructure team — FutureSkill Engineering.

## Related repos

| Repo | Purpose |
| --- | --- |
| [terragrunt](https://github.com/LikeMeX/terragrunt) | Provisions the GKE clusters this chart deploys into |
| [github-reuse-workflow](https://github.com/LikeMeX/github-reuse-workflow) | `deploy-to-cluster.yaml` drives the Helm install |
| [fs-infrastructure](https://github.com/LikeMeX/fs-infrastructure) | Canonical architecture overview |
