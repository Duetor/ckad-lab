# 06 — Troubleshooting a broken application

**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-06`  ·  **Suggested time:** 9 min

## Context

In `ckad-06`, the team deployed a Deployment `backend`, its Service `backend` and a pod `worker`.
Nothing works. Resource names must **not** change.

## Tasks

1. The Service `backend` must answer over HTTP (port **80**) from a pod in the namespace:
   `k run tmp --rm -it --image=busybox:1.36 -n ckad-06 -- wget -qO- http://backend`
   Find and fix **all** the problems (there are several).
2. The pod `worker` is in CrashLoopBackOff.
   - Write the **exact error message** printed by the container to `~/ckad-answers/06-worker-error.txt`.
   - Fix the pod so it becomes `Running` by setting the variable `DB_HOST=postgres.ckad-06.svc`.
3. Write the `Warning` events of the namespace, sorted by date (`.lastTimestamp`),
   to `~/ckad-answers/06-events.txt`.

## Hints

- `k get pods,svc,endpointslices -n ckad-06` ; `k describe pod ...`
- Compare the Service `selector` with the actual pod labels (`--show-labels`).
- Compare the Service `targetPort` with the port the container listens on.
- `k logs worker -n ckad-06 --previous`
- You can't change the env of an existing pod: `k get pod worker -o yaml > w.yaml`, edit, then `k replace --force -f w.yaml`.
- `k get events --field-selector type=Warning --sort-by=.lastTimestamp`
