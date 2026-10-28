#!/usr/bin/env bash
# Solution — exercice 07
set -euo pipefail
NS=ckad-07
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"
LAB="${CKAD_LAB_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

kubectl create cm app-config -n "$NS" --from-literal=APP_MODE=production --from-literal=APP_PORT=8080
kubectl create cm web-content -n "$NS" --from-file="$LAB/exercises/07-config-secrets/files/index.html"
kubectl create secret generic db-creds -n "$NS" --from-literal=username=admin --from-literal='password=S3cr3t!'

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["sleep", "3600"]
      envFrom:
        - configMapRef:
            name: app-config
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-creds
              key: password
      volumeMounts:
        - name: html
          mountPath: /usr/share/html
        - name: db
          mountPath: /etc/db
          readOnly: true
  volumes:
    - name: html
      configMap:
        name: web-content
    - name: db
      secret:
        secretName: db-creds
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/app --timeout=120s

kubectl get secret db-creds -n "$NS" -o jsonpath='{.data.username}' | base64 -d > "$ANS/07-username.txt"
