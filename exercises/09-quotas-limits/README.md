# 09 — ResourceQuota and LimitRange

**Domain:** Application Environment, Configuration and Security
**Namespace:** `ckad-09`  ·  **Suggested time:** 7 min

## Tasks

1. Create the ResourceQuota `team-quota`:
   `requests.cpu=1`, `requests.memory=1Gi`, `limits.cpu=2`, `limits.memory=2Gi`, `pods=5`.
2. Create the LimitRange `defaults` (type `Container`):
   - `defaultRequest`: `cpu: 100m`, `memory: 128Mi`
   - `default` (limits): `cpu: 200m`, `memory: 256Mi`
3. Create the Deployment `worker` (image `busybox:1.36`, command `sleep 3600`, **3 replicas**)
   **without** setting any resources: it must inherit the default values.
4. Try to create a pod `big` (image `busybox:1.36`, `sleep 3600`) requesting `memory: 2Gi`
   as request and limit. Creation must fail: copy the error message to
   `~/ckad-answers/09-quota-error.txt`.

## Hints

- `k create quota team-quota --hard=requests.cpu=1,requests.memory=1Gi,...`
- There's no `kubectl create` for a LimitRange: `k explain limitrange.spec.limits`
- `k describe quota team-quota -n ckad-09` shows current usage.
- Use a small YAML + `2> ~/ckad-answers/09-quota-error.txt` to capture the error.
