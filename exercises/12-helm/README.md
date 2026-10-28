# 12 — Helm : install, upgrade, rollback

**Domaine :** Application Deployment
**Namespace :** `ckad-12`  ·  **Temps conseillé :** 7 min

## Contexte

Un chart local est fourni : `$CKAD_LAB_DIR/exercises/12-helm/chart/webapp`.

## Tâches

1. Installe la release `shop` de ce chart dans `ckad-12` avec `replicaCount=2` et `image.tag=1.27-alpine`.
2. Fais un **upgrade** de la release pour passer `service.type=NodePort`, **en conservant** les valeurs précédentes.
3. Fais un nouvel upgrade avec `image.tag=9.9-broken` (en conservant les valeurs), constate le problème,
   puis fais un **rollback** vers la révision 2.
4. Écris dans `~/ckad-answers/12-values.yaml` les valeurs utilisateur de la release (`helm get values`).
5. Écris dans `~/ckad-answers/12-releases.txt` la liste des releases Helm de **tous** les namespaces.

## Indices

- `helm install shop <chemin> -n ckad-12 --set replicaCount=2,image.tag=1.27-alpine`
- `helm upgrade ... --reuse-values --set service.type=NodePort`
- `helm history shop -n ckad-12` ; `helm rollback shop 2 -n ckad-12`
- `helm list -A`
- Avant d'installer : `helm template` ou `helm show values` pour voir ce que fait le chart.
