# 03 — Rolling update and rollback

**Domain:** Application Deployment
**Namespace:** `ckad-03`  ·  **Suggested time:** 7 min

## Context

The Deployment `web` was just updated by a colleague… and nothing starts anymore.

## Tasks

1. Write to `~/ckad-answers/03-revision1.txt` the **image** used by **revision 1**
   of the Deployment `web` (a single line, e.g. `nginx:x.y`).
2. Roll back to the **last working revision** of the Deployment (do not recreate it).
3. Configure the update strategy: `maxSurge: 1` and `maxUnavailable: 0`.
4. Scale the Deployment to **4 replicas** and check they are all available.
5. Add the annotation `kubernetes.io/change-cause="rollback after broken release"` to the Deployment.

## Hints

- `k rollout history deploy/web -n ckad-03` then `--revision=1` for details.
- `k rollout undo deploy/web -n ckad-03` (or `--to-revision=N`).
- `k describe pod` or `k get pods` to understand why the latest version doesn't start.
- `k patch deploy web -p '{"spec":{"strategy":{...}}}'` or `k edit`.
- `k annotate deploy web kubernetes.io/change-cause="..."`
