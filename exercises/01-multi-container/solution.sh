#!/usr/bin/env bash
# Solution — exercise 01
set -euo pipefail
NS=ckad-01

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: logger
spec:
  volumes:
    - name: logs
      emptyDir: {}
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh", "-c", "while true; do date >> /var/log/app/app.log; sleep 2; done"]
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
    - name: sidecar
      image: busybox:1.36
      command: ["sh", "-c", "tail -n+1 -F /var/log/app/app.log"]
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
YAML

kubectl wait -n "$NS" --for=condition=Ready pod/logger --timeout=120s
sleep 5
kubectl logs logger -c sidecar -n "$NS" --tail=3
