#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-22
fresh_ns "$NS"
TOKEN="tok-$(date +%s | tail -c 6)-$RANDOM"
kubectl create secret generic app-token -n "$NS" --from-literal=value="$TOKEN" >/dev/null
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: locked
spec:
  containers:
    - name: app
      image: registry.k8s.io/pause:3.10
      securityContext:
        runAsUser: 0
      volumeMounts:
        - name: token
          mountPath: /etc/token
          readOnly: true
  volumes:
    - name: token
      secret:
        secretName: app-token
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/locked --timeout=120s >/dev/null
