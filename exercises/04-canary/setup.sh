#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-04
fresh_ns "$NS"
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-v1
spec:
  replicas: 4
  selector:
    matchLabels: {app: shop, version: v1}
  template:
    metadata:
      labels: {app: shop, version: v1}
    spec:
      containers:
        - name: nginx
          image: nginx:1.25-alpine
          ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata:
  name: shop
spec:
  selector: {app: shop, version: v1}
  ports: [{port: 80, targetPort: 80}]
YAML
