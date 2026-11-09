# 01 — Multi-container pod with a sidecar

**Domain:** Application Design and Build
**Namespace:** `ckad-01`  ·  **Suggested time:** 6 min

## Context

A team wants to collect the logs of an application that only writes to a file.

## Tasks

In namespace `ckad-01`, create a pod named `logger`:

1. A container `app` (image `busybox:1.36`) running:
   `sh -c 'while true; do date >> /var/log/app/app.log; sleep 2; done'`
2. A container `sidecar` (image `busybox:1.36`) running:
   `sh -c 'tail -n+1 -F /var/log/app/app.log'`
3. Both containers share an `emptyDir` volume named `logs`, mounted at `/var/log/app`.

Then check that `kubectl logs logger -c sidecar -n ckad-01` prints dates.

> A "native" sidecar (initContainer with `restartPolicy: Always`) is also accepted.

## Hints

- `k run logger --image=busybox:1.36 -n ckad-01 $do -- sh -c '...' > pod.yaml` gives you a skeleton.
- Duplicate the container block, rename both, then add `volumes:` at pod level and `volumeMounts:` in each container.
- `k explain pod.spec.volumes.emptyDir`
