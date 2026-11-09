# 17 — PVC and data persistence

**Domain:** Application Environment, Configuration and Security
**Namespace:** `ckad-17`  ·  **Suggested time:** 7 min

## Tasks

1. Create a PVC `data-pvc`: `256Mi`, access mode `ReadWriteOnce`, StorageClass `standard`.
2. Create a pod `writer` (image `busybox:1.36`) that mounts the PVC at `/data` and runs
   `sh -c 'echo persisted-$(hostname) > /data/state.txt && sleep 3600'`.
3. Once the file is written, **delete** the pod `writer`.
4. Create a pod `reader` (image `busybox:1.36`, command `sleep 3600`) that mounts the same PVC at `/data`
   **read-only**.
5. Write the **name of the PersistentVolume** bound to `data-pvc` to `~/ckad-answers/17-pv.txt`.

Check: `k exec reader -n ckad-17 -- cat /data/state.txt` prints `persisted-writer`.

## Hints

- There's no `kubectl create pvc`: `k explain pvc.spec` or the docs ("Configure a Pod to Use a PersistentVolume").
- `k get sc` shows minikube's default StorageClass.
- In the pod: `volumes[].persistentVolumeClaim.claimName`.
- `k get pvc data-pvc -n ckad-17 -o jsonpath='{.spec.volumeName}'`
