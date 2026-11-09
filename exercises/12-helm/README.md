# 12 — Helm: install, upgrade, rollback

**Domain:** Application Deployment
**Namespace:** `ckad-12`  ·  **Suggested time:** 7 min

## Context

A local chart is provided: `$CKAD_LAB_DIR/exercises/12-helm/chart/webapp`.

## Tasks

1. Install the release `shop` from this chart in `ckad-12` with `replicaCount=2` and `image.tag=1.27-alpine`.
2. **Upgrade** the release to set `service.type=NodePort`, **keeping** the previous values.
3. Upgrade again with `image.tag=9.9-broken` (keeping the values), observe the problem,
   then **roll back** to revision 2.
4. Write the user-supplied values of the release (`helm get values`) to `~/ckad-answers/12-values.yaml`.
5. Write the list of Helm releases across **all** namespaces to `~/ckad-answers/12-releases.txt`.

## Hints

- `helm install shop <path> -n ckad-12 --set replicaCount=2,image.tag=1.27-alpine`
- `helm upgrade ... --reuse-values --set service.type=NodePort`
- `helm history shop -n ckad-12` ; `helm rollback shop 2 -n ckad-12`
- `helm list -A`
- Before installing: `helm template` or `helm show values` to see what the chart does.
