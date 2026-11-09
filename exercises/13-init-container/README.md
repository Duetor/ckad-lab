# 13 — Init container that prepares content

**Domain:** Application Design and Build
**Namespace:** `ckad-13`  ·  **Suggested time:** 6 min
*Variant of exercise 01 (multi-container pod).*

## Tasks

In `ckad-13`, create a pod `web-init`:

1. An **init container** `fetch` (image `busybox:1.36`) running
   `sh -c 'echo "Hello from init" > /work/index.html'`.
2. A main container `web` (image `nginx:1.27-alpine`) that serves this file.
3. Both share an `emptyDir` volume named `html`: mounted at `/work` in `fetch`
   and at `/usr/share/nginx/html` in `web`.
4. The pod must have the label `app=web-init`.
5. Expose the pod with a Service `web-init` (ClusterIP, port 80).

Check: `k exec web-init -n ckad-13 -- wget -qO- localhost` must print `Hello from init`.

## Hints

- `initContainers:` sits at the same level as `containers:` in `spec`.
- An init container must **complete** successfully before the main containers start.
- If the pod is stuck in `Init:0/1`: `k logs web-init -c fetch -n ckad-13`.
- `k expose pod web-init --port=80 -n ckad-13`
