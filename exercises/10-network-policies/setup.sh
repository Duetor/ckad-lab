#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-10
fresh_ns "$NS"
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: frontend, labels: {role: frontend}}
spec:
  containers: [{name: c, image: busybox:1.36, command: [sleep, "3600"]}]
---
apiVersion: v1
kind: Pod
metadata: {name: intruder, labels: {role: other}}
spec:
  containers: [{name: c, image: busybox:1.36, command: [sleep, "3600"]}]
---
apiVersion: v1
kind: Pod
metadata: {name: backend, labels: {role: backend}}
spec:
  containers: [{name: c, image: nginx:1.27-alpine, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Pod
metadata: {name: db, labels: {role: db}}
spec:
  containers: [{name: c, image: nginx:1.27-alpine, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: backend}
spec: {selector: {role: backend}, ports: [{port: 80}]}
---
apiVersion: v1
kind: Service
metadata: {name: db}
spec: {selector: {role: db}, ports: [{port: 80}]}
YAML
kubectl wait -n "$NS" --for=condition=Ready pod --all --timeout=180s >/dev/null
