# 08 — ServiceAccount, RBAC and SecurityContext

**Domain:** Application Environment, Configuration and Security
**Namespace:** `ckad-08`  ·  **Suggested time:** 9 min

## Tasks

1. Create the ServiceAccount `monitor`.
2. Create the Role `pod-reader` allowing `get`, `list`, `watch` on `pods` (and nothing else).
3. Bind this Role to the ServiceAccount `monitor` with the RoleBinding `monitor-binding`.
4. Create a pod `secure` (image `busybox:1.36`, command `sleep 3600`) that:
   - uses the ServiceAccount `monitor`;
   - runs with UID `1000` and GID `3000` (at **pod** level);
   - prevents privilege escalation, has a **read-only** root filesystem,
     and drops **all** Linux capabilities (at **container** level).
5. Use `kubectl auth can-i` to check that `monitor` can list pods but can **not** delete them.

## Hints

- `k create sa monitor` ; `k create role pod-reader --verb=get,list,watch --resource=pods`
- `k create rolebinding monitor-binding --role=pod-reader --serviceaccount=ckad-08:monitor`
- `k auth can-i list pods --as=system:serviceaccount:ckad-08:monitor -n ckad-08`
- `k explain pod.spec.securityContext` vs `k explain pod.spec.containers.securityContext`
