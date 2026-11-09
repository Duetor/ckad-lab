#!/usr/bin/env bash
# Solution — exercise 14
set -euo pipefail
NS=ckad-14

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
      volumes:
        - name: logs
          emptyDir: {}
      initContainers:
        - name: log-shipper           # native sidecar
          image: busybox:1.36
          restartPolicy: Always
          command: ["sh", "-c", "tail -n+1 -F /var/log/nginx/access.log"]
          resources:
            requests: {cpu: 10m, memory: 16Mi}
          volumeMounts:
            - name: logs
              mountPath: /var/log/nginx
              readOnly: true
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: logs
              mountPath: /var/log/nginx
YAML
kubectl rollout status deploy/api -n "$NS" --timeout=180s

POD=$(kubectl get pods -n "$NS" -l app=api -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD" -n "$NS" -c nginx -- wget -qO- localhost >/dev/null
sleep 2
kubectl logs "$POD" -n "$NS" -c log-shipper
