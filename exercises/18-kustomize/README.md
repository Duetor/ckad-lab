# 18 — Kustomize: production overlay

**Domain:** Application Deployment
**Namespace:** `ckad-18`  ·  **Suggested time:** 8 min

## Context

A Kustomize base was copied to `~/ckad-answers/18-kustomize/base/` (Deployment + Service `web`).

## Tasks

Create the overlay `~/ckad-answers/18-kustomize/overlays/prod/kustomization.yaml` which, from the base:

1. deploys into namespace `ckad-18`;
2. prefixes names with `prod-`;
3. adds the label `env=prod` to all resources **and** to the selectors;
4. scales the Deployment to **3 replicas**;
5. changes the `nginx` image tag to `1.27-alpine`.

Then apply the overlay with `kubectl apply -k`. **Do not modify the base.**

## Hints

- `k kustomize ~/ckad-answers/18-kustomize/overlays/prod` renders without applying.
- Useful fields: `resources: [../../base]`, `namespace`, `namePrefix`, `labels` (with `includeSelectors: true`),
  `replicas`, `images`.
- Docs: kubernetes.io → "Declarative Management of Kubernetes Objects Using Kustomize".
