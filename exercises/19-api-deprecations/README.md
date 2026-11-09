# 19 — Migrating deprecated APIs

**Domain:** Application Deployment
**Namespace:** `ckad-19`  ·  **Suggested time:** 9 min

## Context

The file `~/ckad-answers/19-legacy.yaml` comes from an old cluster.
`kubectl apply -f ~/ckad-answers/19-legacy.yaml -n ckad-19` fails.

## Tasks

1. Fix **this file** (in place) so it uses API versions supported by your cluster,
   then apply it in `ckad-19`. Names, images, ports, schedule, thresholds… must stay the same.
2. Write the current group/version of Ingress (format `group/version`), as given by
   `kubectl api-resources`, to `~/ckad-answers/19-ingress-api.txt`.

Check: the 5 resources exist and the Deployment has 2 available replicas.

## Hints

- `k api-resources | grep -Ei 'deploy|ingress|cronjob|horizontal'`
- `k explain ingress.spec.rules.http.paths --api-version=networking.k8s.io/v1`
- Moving from `apps/v1beta1` to `apps/v1` makes `spec.selector` **mandatory**.
- In `networking.k8s.io/v1`, `pathType` is mandatory and the backend becomes `service.name` / `service.port.number`.
- `k apply --dry-run=server -f ...` validates without creating anything.
