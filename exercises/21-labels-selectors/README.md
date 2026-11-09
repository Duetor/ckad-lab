# 21 — Labels, selectors and annotations

**Domain:** Application Deployment
**Namespace:** `ckad-21`  ·  **Suggested time:** 6 min

## Context

Namespace `ckad-21` contains 7 pods with various labels (`env`, `tier`, `temp`…).

## Tasks

1. Write to `~/ckad-answers/21-prod-frontend.txt` the **names** of the pods with `env=prod` **and** `tier=frontend`,
   one per line, sorted alphabetically (no header).
2. Add the label `audit=true` to **all** `env=prod` pods.
3. Remove the label `temp` from **all** pods that have it.
4. Add the annotation `owner=team-a` to the `tier=backend` pods.
5. Delete the `tier=cache` pods.
6. Write to `~/ckad-answers/21-not-prod.txt` the names of the pods whose `env` is **not** `prod`
   (pods without an `env` label included), one per line, sorted.

## Hints

- `k get pods -n ckad-21 --show-labels` ; `-L env,tier` for columns.
- `-l 'env=prod,tier=frontend'`, `-l 'env!=prod'`, `-l '!temp'`, `-l 'env in (dev,staging)'`
- `-o name` gives `pod/xxx` ; `-o custom-columns=NAME:.metadata.name --no-headers` gives just the name.
- `k label pods -l env=prod audit=true` ; `k label pods --all temp-` ; `k annotate pods -l ... owner=team-a`
