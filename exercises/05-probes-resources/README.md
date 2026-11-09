# 05 — Probes and resources

**Domain:** Application Observability and Maintenance
**Namespace:** `ckad-05`  ·  **Suggested time:** 7 min

## Tasks

Create a Deployment `api` in `ckad-05`:

1. Image `nginx:1.27-alpine`, **2 replicas**, container port `80`.
2. An HTTP **readinessProbe** `GET /` on port 80, `initialDelaySeconds: 5`, `periodSeconds: 10`.
3. A TCP **livenessProbe** on port 80, `periodSeconds: 15`, `failureThreshold: 3`.
4. An HTTP **startupProbe** `GET /` on port 80 with `failureThreshold: 30` and `periodSeconds: 2`.
5. Resources: requests `cpu: 100m`, `memory: 64Mi` — limits `cpu: 250m`, `memory: 128Mi`.
6. Write the output of `kubectl top pods -n ckad-05` to `~/ckad-answers/05-top.txt`
   (metrics-server may take ~1 min to report values).

## Hints

- `k create deploy api --image=nginx:1.27-alpine --replicas=2 --port=80 -n ckad-05 $do > api.yaml`
- `k explain deploy.spec.template.spec.containers.readinessProbe`
- `k set resources deploy api --requests=cpu=100m,memory=64Mi --limits=cpu=250m,memory=128Mi`
