#!/usr/bin/env bash
# Solution — exercise 20
set -euo pipefail
NS=ckad-20
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"
DIR="$ANS/20-build"
PROFILE="${MINIKUBE_PROFILE:-ckad}"

cat > "$DIR/Dockerfile" <<'DOCKERFILE'
FROM nginx:1.27-alpine
LABEL maintainer="ckad"
COPY index.html /usr/share/nginx/html/index.html
DOCKERFILE

# Git Bash: minikube.exe expects a Windows path
command -v cygpath >/dev/null 2>&1 && DIR=$(cygpath -m "$DIR")
minikube image build -t ckad/hello:v1 "$DIR" -p "$PROFILE"
minikube image ls -p "$PROFILE" | grep ckad/hello

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
spec:
  replicas: 1
  selector:
    matchLabels: {app: hello}
  template:
    metadata:
      labels: {app: hello}
    spec:
      containers:
        - name: hello
          image: ckad/hello:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  type: NodePort
  selector: {app: hello}
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
YAML
kubectl rollout status deploy/hello -n "$NS" --timeout=120s
