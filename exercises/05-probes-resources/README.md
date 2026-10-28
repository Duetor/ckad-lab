# 05 — Probes et ressources

**Domaine :** Application Observability and Maintenance
**Namespace :** `ckad-05`  ·  **Temps conseillé :** 7 min

## Tâches

Crée un Deployment `api` dans `ckad-05` :

1. Image `nginx:1.27-alpine`, **2 réplicas**, port conteneur `80`.
2. Une **readinessProbe** HTTP `GET /` sur le port 80, `initialDelaySeconds: 5`, `periodSeconds: 10`.
3. Une **livenessProbe** TCP sur le port 80, `periodSeconds: 15`, `failureThreshold: 3`.
4. Une **startupProbe** HTTP `GET /` sur le port 80 avec `failureThreshold: 30` et `periodSeconds: 2`.
5. Ressources : requests `cpu: 100m`, `memory: 64Mi` — limits `cpu: 250m`, `memory: 128Mi`.
6. Écris dans `~/ckad-answers/05-top.txt` la sortie de `kubectl top pods -n ckad-05`
   (le metrics-server peut mettre ~1 min à remonter des valeurs).

## Indices

- `k create deploy api --image=nginx:1.27-alpine --replicas=2 --port=80 -n ckad-05 $do > api.yaml`
- `k explain deploy.spec.template.spec.containers.readinessProbe`
- `k set resources deploy api --requests=cpu=100m,memory=64Mi --limits=cpu=250m,memory=128Mi`
