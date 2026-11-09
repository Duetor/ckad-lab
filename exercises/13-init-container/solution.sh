#!/usr/bin/env bash
# Solution — exercise 13
set -euo pipefail
NS=ckad-13

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: web-init
  labels:
    app: web-init
spec:
  volumes:
    - name: html
      emptyDir: {}
  initContainers:
    - name: fetch
      image: busybox:1.36
      command: ["sh", "-c", "echo 'Hello from init' > /work/index.html"]
      volumeMounts:
        - name: html
          mountPath: /work
  containers:
    - name: web
      image: nginx:1.27-alpine
      ports:
        - containerPort: 80
      volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/web-init --timeout=120s
kubectl expose pod web-init --port=80 -n "$NS"
kubectl exec web-init -n "$NS" -c web -- wget -qO- localhost
