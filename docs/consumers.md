---
title: fs-app-chart Consumers
repo: fs-app-chart
layer: infra
tech: Helm
default_branch: main
updated: 2026-04-24
source_path: docs/consumers.md
---

## Consumers — repos that use fs-app-chart

All FutureSkill application repos that deploy to GKE include `fs-app-chart` as a Git submodule and reference it in their `deploy-to-cluster` workflow step.

### Known consumers

| Repo | Environment(s) | Notes |
| --- | --- | --- |
| [LikeMeX/fs-backend](https://github.com/LikeMeX/fs-backend) | dev, production | Main API server |
| [LikeMeX/fs-frontend](https://github.com/LikeMeX/fs-frontend) | dev, production | Next.js web app (static export + cluster deploy) |
| [LikeMeX/fs-worker](https://github.com/LikeMeX/fs-worker) | dev, production | Background job service |

> If your repo uses this chart and is not listed, open a PR to add it.

### How a consumer repo is set up

```bash
# 1. Add the chart as a submodule
git submodule add https://github.com/LikeMeX/fs-app-chart.git fs-app-chart

# 2. Create per-env values files
mkdir -p deploy
cp fs-app-chart/values.yaml deploy/values-dev.yaml
cp fs-app-chart/values.yaml deploy/values-production.yaml
# Edit each file to set image.repository, ingress, resources, etc.

# 3. Reference the reusable workflow in .github/workflows/deploy.yaml
# (see github-reuse-workflow docs/consumers.md for the call snippet)
```

### Workflow integration

The `deploy-to-cluster.yaml` reusable workflow (in `github-reuse-workflow`) drives the install:

```yaml
# .github/workflows/deploy.yaml in a consumer repo
jobs:
  deploy:
    uses: LikeMeX/github-reuse-workflow/.github/workflows/deploy-to-cluster.yaml@main
    with:
      environment: dev
      docker-image: gcr.io/futureskillstaging/my-service
      docker-tag: ${{ needs.build.outputs.tag }}
      workload_identity_provider: projects/1097293104076/locations/global/workloadIdentityPools/...
      service_account: deployer@futureskillstaging.iam.gserviceaccount.com
      GKE_CLUSTER: fs-cluster-staging
      GKE_ZONE: asia-southeast1-b
      RELEASE_NAME: my-service
    secrets:
      GH_PAT: ${{ secrets.GH_PAT }}
```
