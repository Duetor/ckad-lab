#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-11
fresh_ns "$NS"
for x in a b; do
  kubectl apply -n "$NS" -f - >/dev/null <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-$x
spec:
  replicas: 1
  selector:
    matchLabels: {app: app-$x}
  template:
    metadata:
      labels: {app: app-$x}
    spec:
      containers:
        - name: echo
          image: hashicorp/http-echo:0.2.3
          args: ["-text=Hello from ${x^^}"]
          ports: [{containerPort: 5678}]
YAML
done
kubectl rollout status deploy/app-a -n "$NS" --timeout=180s >/dev/null
kubectl rollout status deploy/app-b -n "$NS" --timeout=180s >/dev/null
