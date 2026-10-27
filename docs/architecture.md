---
title: fs-app-chart Architecture
repo: fs-app-chart
layer: infra
tech: Helm
default_branch: main
updated: 2026-04-24
source_path: docs/architecture.md
---

## Architecture — fs-app-chart

**Canonical overview:** [fs-infrastructure architecture](https://github.com/LikeMeX/fs-infrastructure/blob/main/docs/architecture.md)

### Chart layout

```
fs-app-chart/
├── Chart.yaml              # name: my-app, version: 0.1.0, appVersion: 0.1.0
├── values.yaml             # Default values (overridden per consumer release)
└── templates/
    ├── _helpers.tpl        # Named template helpers (fullname, labels, selectorLabels)
    ├── deployment.yaml     # Deployment — image, env, envFrom (configmap + secret), probes
    ├── service.yaml        # ClusterIP, port 80 → 3000
    ├── ingress.yaml        # Optional ingress (networking.k8s.io/v1, TLS supported)
    ├── hpa.yaml            # HPA v2 — CPU and/or memory utilisation targets
    ├── configmap.yaml      # Non-sensitive env vars (from .Values.env)
    ├── secret.yaml         # Sensitive values (from .Values.secrets)
    ├── serviceaccount.yaml # Optional K8s ServiceAccount
    ├── NOTES.txt           # Post-install notes
    └── tests/
        └── test-connection.yaml
```

### Chart → release → Kubernetes flow

```mermaid
flowchart LR
    subgraph Consumer["Consumer repo (e.g. fs-backend)"]
        SM[fs-app-chart submodule]
        VF["deploy/values-dev.yaml\ndeploy/values-production.yaml"]
        ENV["env/.env.dev\nenv/.env.production"]
        SEC["secrets/.env.enc.dev\n(SOPS-encrypted)"]
    end

    subgraph GHW["github-reuse-workflow"]
        WF["deploy-to-cluster.yaml\n(reusable workflow_call)"]
    end

    subgraph GKE["GKE Cluster (per env)"]
        CM[ConfigMap\nRELEASE_NAME-my-app]
        SK[Secret\nRELEASE_NAME-secrets]
        DEP[Deployment\nPods]
        SVC[Service ClusterIP]
        ING[Ingress\n(optional)]
        HPA[HPA\n(optional)]
    end

    VF --> WF
    ENV --> CM
    SEC -->|sops -d| SK
    SM --> WF
    WF -->|helm upgrade --install| DEP
    WF --> CM
    WF --> SK
    DEP --> SVC
    SVC --> ING
    DEP --> HPA
```

### Env injection sequence

1. `deploy-to-cluster.yaml` copies `values-<env>.yaml` to `values.yaml` (substituting `<DOCKER_TAG>`).
2. `kubectl create configmap` from `env/.env.<env>` — mounts as `envFrom.configMapRef`.
3. `sops -d` decrypts `secrets/.env.enc.<env>` → `kubectl create secret` — mounts as `envFrom.secretRef`.
4. Additional external secrets can be referenced via `.Values.external_secret_refs[].name`.
5. `helm upgrade --install` renders all templates and applies to the target namespace.
