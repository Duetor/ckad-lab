# 22 — Debugging without a shell (kubectl debug)

**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-22`  ·  **Suggested time:** 8 min

## Context

The pod `locked` in `ckad-22` runs a **minimal image with no shell** (`pause`).
A token is mounted in its container `app`, at `/etc/token/value`.
`k exec locked -- sh` can't work.

## Tasks

1. Read the token **from the container `app`** using an **ephemeral container** (`kubectl debug`)
   that targets this container, and write its value to `~/ckad-answers/22-token.txt`.
   (Not allowed: reading the Secret through the API.)
2. Create a **debugging copy** of the pod named `locked-debug`, in which an extra container
   `shell` (image `busybox:1.36`, command `sleep 3600`) shares the process namespace.
3. The original pod `locked` must still be running.

## Hints

- `k debug -it locked -n ckad-22 --image=busybox:1.36 --target=app -- sh`
- With `--target`, the ephemeral container sees the processes of `app`: the filesystem of `app`
  is reachable through `/proc/<pid>/root/` (the main process is often PID 1).
- `k debug locked --copy-to=locked-debug --share-processes --container=shell --image=busybox:1.36 -- sleep 3600`
- `k get pod locked -o jsonpath='{.spec.ephemeralContainers[*].name}'`
