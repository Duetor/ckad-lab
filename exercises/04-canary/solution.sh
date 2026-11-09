#!/usr/bin/env bash
# Solution — exercise 04
set -euo pipefail
NS=ckad-04

# 1. Canary Deployment (1 pod out of 5 = 20%)
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

# 2. The Service no longer filters on version (JSON patch to REMOVE the key)
kubectl patch svc shop -n "$NS" --type=json -p '[{"op":"remove","path":"/spec/selector/version"}]'

# 3. Verification
kubectl rollout status deploy/shop-v2 -n "$NS" --timeout=120s
kubectl rollout status deploy/shop-v1 -n "$NS" --timeout=120s
kubectl get endpointslices -n "$NS" -l kubernetes.io/service-name=shop
