# 14 — Native sidecar in a Deployment

**Domain:** Application Design and Build
**Namespace:** `ckad-14`  ·  **Suggested time:** 7 min
*Variant of exercise 01, using the "native sidecar" syntax (Kubernetes ≥ 1.29).*

## Tasks

In `ckad-14`, create a Deployment `api` (**2 replicas**, label `app=api`):

1. Container `nginx` (image `nginx:1.27-alpine`, port 80).
2. An `emptyDir` volume named `logs`, mounted at `/var/log/nginx` in `nginx`
   (nginx will then write a real `access.log` file there).
3. A **native sidecar** `log-shipper` (image `busybox:1.36`) — i.e. declared in
   `initContainers` with `restartPolicy: Always` — running
   `sh -c 'tail -n+1 -F /var/log/nginx/access.log'` and mounting `logs` at `/var/log/nginx` **read-only**.
4. The sidecar must have resources: requests `cpu: 10m`, `memory: 16Mi`.

Check: after a `wget` on a pod, `k logs <pod> -c log-shipper` shows the `GET /` request.

## Hints

- A native sidecar starts **before** the main containers and keeps running for the pod's whole life,
  unlike a classic init container.
- `k explain pod.spec.initContainers.restartPolicy`
- Without the volume, `/var/log/nginx/access.log` in the official image is a link to `/dev/stdout`.
- `k exec <pod> -c nginx -n ckad-14 -- wget -qO- localhost`
