# 04 — Canary deployment

**Domain:** Application Deployment
**Namespace:** `ckad-04`  ·  **Suggested time:** 7 min

## Context

The Deployment `shop-v1` (4 replicas) is exposed by the Service `shop`.
We want to test a new version on **20% of the traffic**.

## Tasks

1. Create a Deployment `shop-v2`:
   - image `nginx:1.27-alpine`
   - pod labels: `app=shop` and `version=v2`
   - a replica count such that v2 gets **20%** of the traffic, without changing `shop-v1`'s replicas
2. Change the Service `shop` so it sends traffic **to both versions**.
3. Check that the Service has 5 endpoints.

## Hints

- 20% of 5 pods = 1 pod.
- The Service currently selects `app=shop,version=v1`: `k get svc shop -n ckad-04 -o yaml`.
- `k create deploy shop-v2 ... $do` generates `app: shop-v2`: fix the labels in the **selector** AND the **template**.
- `k get endpointslices -n ckad-04 -l kubernetes.io/service-name=shop`
