---
title: fs-app-chart Values Reference
repo: fs-app-chart
layer: infra
tech: Helm
default_branch: main
updated: 2026-04-24
source_path: docs/env.md
---

## Values Schema — fs-app-chart

All keys are sourced from `values.yaml`. Override per-release in `deploy/values-<env>.yaml`.

### Core

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `replicaCount` | int | `1` | Number of pod replicas (ignored when HPA is enabled) |
| `nameOverride` | string | `""` | Override chart name portion of release name |
| `fullnameOverride` | string | `""` | Override the full release name |
| `labels` | map | `{app: test, environment: dev}` | Extra labels added to all pods |

### Image

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `image.repository` | string | `nginx` | Container image repository |
| `image.tag` | string | `""` | Image tag; defaults to `Chart.appVersion` if empty |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `imagePullSecrets` | list | `[]` | List of image pull secret names |

### Service

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `service.type` | string | `ClusterIP` | Kubernetes service type |
| `service.port` | int | `80` | Service port (maps to container port `3000`) |

### Ingress

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `ingress.enabled` | bool | `false` | Create an Ingress resource |
| `ingress.className` | string | `""` | IngressClass name (e.g. `nginx`) |
| `ingress.annotations` | map | `{}` | Ingress annotations |
| `ingress.hosts` | list | see values.yaml | Host rules with path definitions |
| `ingress.tls` | list | `[]` | TLS configuration (secretName + hosts) |

### Resources

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `resources` | map | `{}` | CPU/memory requests and limits |

### Autoscaling (HPA)

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `autoscaling.enabled` | bool | `false` | Enable HorizontalPodAutoscaler |
| `autoscaling.minReplicas` | int | `1` | Minimum replicas |
| `autoscaling.maxReplicas` | int | `100` | Maximum replicas |
| `autoscaling.targetCPUUtilizationPercentage` | int | `80` | CPU utilisation target (%) |
| `autoscaling.targetMemoryUtilizationPercentage` | int | — | Memory utilisation target (%, optional) |

### Environment & secrets

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `env` | list | `[]` | Additional env vars injected directly into the container |
| `secrets` | map | `null` | Key/value pairs rendered into a Kubernetes Secret and mounted via `envFrom` |
| `external_secret_refs` | list | `[]` | List of `{name: <secretName>}` for pre-existing Secrets to mount via `envFrom` |

### Probes

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `livenessProbe` | map | `{}` | Liveness probe spec |
| `readinessProbe` | map | `{}` | Readiness probe spec |
| `startupProbe` | map | `{}` | Startup probe spec |

### Pod

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `podAnnotations` | map | `{}` | Annotations added to pods |
| `podSecurityContext` | map | `{}` | Pod-level security context |
| `securityContext` | map | `{}` | Container-level security context |
| `nodeSelector` | map | `{}` | Node selector |
| `tolerations` | list | `[]` | Tolerations |
| `affinity` | map | `{}` | Affinity rules |

### ServiceAccount

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `serviceAccount.create` | bool | `true` | Create a ServiceAccount |
| `serviceAccount.annotations` | map | `{}` | Annotations (e.g. Workload Identity binding) |
| `serviceAccount.name` | string | `""` | Override service account name |
