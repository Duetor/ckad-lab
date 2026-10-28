#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-06
fresh_ns "$NS"
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels: {app: backend}
  template:
    metadata:
      labels: {app: backend, tier: api}
    spec:
      containers:
        - name: web
          image: ngnix:1.27-alpine
          ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector: {app: backend, tier: backnd}
  ports: [{port: 80, targetPort: 8080}]
---
apiVersion: v1
kind: Pod
metadata:
  name: worker
spec:
  containers:
    - name: worker
      image: busybox:1.36
      command:
        - sh
        - -c
        - |
          if [ -z "$DB_HOST" ]; then echo "FATAL: environment variable DB_HOST is not set"; exit 1; fi
          echo "connected to $DB_HOST"; sleep 3600
YAML
