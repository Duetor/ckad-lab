#!/usr/bin/env bash
# Solution — exercice 04
set -euo pipefail
NS=ckad-04

# 1. Deployment canary (1 pod sur 5 = 20 %)
kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-v2
spec:
  replicas: 1
  selector:
    matchLabels: {app: shop, version: v2}
  template:
    metadata:
      labels: {app: shop, version: v2}
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports: [{containerPort: 80}]
YAML

# 2. Le Service ne filtre plus sur la version (patch JSON pour SUPPRIMER la clé)
kubectl patch svc shop -n "$NS" --type=json -p '[{"op":"remove","path":"/spec/selector/version"}]'

# 3. Vérification
kubectl rollout status deploy/shop-v2 -n "$NS" --timeout=120s
kubectl rollout status deploy/shop-v1 -n "$NS" --timeout=120s
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=shop
