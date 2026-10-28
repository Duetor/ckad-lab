# 04 — Déploiement canary

**Domaine :** Application Deployment
**Namespace :** `ckad-04`  ·  **Temps conseillé :** 7 min

## Contexte

Le Deployment `shop-v1` (4 réplicas) est exposé par le Service `shop`.
On veut tester une nouvelle version sur **20 % du trafic**.

## Tâches

1. Crée un Deployment `shop-v2` :
   - image `nginx:1.27-alpine`
   - labels des pods : `app=shop` et `version=v2`
   - nombre de réplicas tel que v2 reçoive **20 %** du trafic sans toucher au nombre de réplicas de `shop-v1`
2. Modifie le Service `shop` pour qu'il envoie le trafic **aux deux versions**.
3. Vérifie que le Service a bien 5 endpoints.

## Indices

- 20 % de 5 pods = 1 pod.
- Le Service sélectionne actuellement `app=shop,version=v1` : `k get svc shop -n ckad-04 -o yaml`.
- `k create deploy shop-v2 ... $do` génère `app: shop-v2` : corrige les labels du **selector** ET du **template**.
- `k get endpointslices -n ckad-04 -l kubernetes.io/service-name=shop`
