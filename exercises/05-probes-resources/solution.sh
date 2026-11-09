#!/usr/bin/env bash
# Solution — exercise 05
set -euo pipefail
NS=ckad-05
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 2
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api}
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          startupProbe:
            httpGet: {path: /, port: 80}
            failureThreshold: 30
            periodSeconds: 2
          readinessProbe:
            httpGet: {path: /, port: 80}
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            tcpSocket: {port: 80}
            periodSeconds: 15
            failureThreshold: 3
          resources:
            requests: {cpu: 100m, memory: 64Mi}
            limits: {cpu: 250m, memory: 128Mi}
YAML
kubectl rollout status deploy/api -n "$NS" --timeout=180s

# metrics-server needs a little time to collect metrics
for _ in $(seq 1 30); do
  kubectl top pods -n "$NS" > "$ANS/05-top.txt" 2>/dev/null && grep -q '^api-' "$ANS/05-top.txt" && break
  sleep 10
done
cat "$ANS/05-top.txt"
