# 16 — Troubleshooting a multi-container pod

**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-16`  ·  **Suggested time:** 8 min
*Variant of exercise 01, troubleshooting side.*

## Context

The pod `report` in `ckad-16` has two containers: `writer` produces a report, `reader` must display it.
The pod doesn't work.

## Tasks

1. Write the **name of the container** that keeps restarting to `~/ckad-answers/16-container.txt`.
2. Write the **reason** of that container's last termination, as reported by Kubernetes
   (e.g. `OOMKilled`, `Error`, `Completed`…), to `~/ckad-answers/16-reason.txt`.
3. Fix the pod so that `reader` displays the report lines, **without** changing:
   the pod name, the container commands, or the `mountPath` of `reader` (`/in`).

Check: `k logs report -c reader -n ckad-16` prints `report line ...` lines.

## Hints

- `k get pod report -n ckad-16` (RESTARTS column), then `k describe pod report`.
- `k get pod report -o jsonpath='{.status.containerStatuses[*].lastState}'`
- Compare **where** `writer` writes and **where** the shared volume is mounted.
- `k get pod report -o yaml > report.yaml`, fix it, then `k replace --force -f report.yaml`.
