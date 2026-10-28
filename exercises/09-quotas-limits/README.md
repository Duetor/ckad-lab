# 09 — ResourceQuota et LimitRange

**Domaine :** Application Environment, Configuration and Security
**Namespace :** `ckad-09`  ·  **Temps conseillé :** 7 min

## Tâches

1. Crée la ResourceQuota `team-quota` :
   `requests.cpu=1`, `requests.memory=1Gi`, `limits.cpu=2`, `limits.memory=2Gi`, `pods=5`.
2. Crée la LimitRange `defaults` (type `Container`) :
   - `defaultRequest` : `cpu: 100m`, `memory: 128Mi`
   - `default` (limits) : `cpu: 200m`, `memory: 256Mi`
3. Crée le Deployment `worker` (image `busybox:1.36`, commande `sleep 3600`, **3 réplicas**)
   **sans** définir de ressources : il doit hériter des valeurs par défaut.
4. Essaie de créer un pod `big` (image `busybox:1.36`, `sleep 3600`) qui demande `memory: 2Gi`
   en request et en limit. La création doit échouer : copie le message d'erreur dans
   `~/ckad-answers/09-quota-error.txt`.

## Indices

- `k create quota team-quota --hard=requests.cpu=1,requests.memory=1Gi,...`
- Pas de `kubectl create` pour une LimitRange : `k explain limitrange.spec.limits`
- `k describe quota team-quota -n ckad-09` montre la consommation.
- `k run big ... --overrides` est pénible : un petit YAML + `2> ~/ckad-answers/09-quota-error.txt`.
