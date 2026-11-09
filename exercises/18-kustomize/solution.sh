#!/usr/bin/env bash
# Solution — exercise 18
set -euo pipefail
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"
O="$ANS/18-kustomize/overlays/prod"
mkdir -p "$O"

cat > "$O/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: ckad-18
namePrefix: prod-
labels:
  - pairs:
      env: prod
    includeSelectors: true
replicas:
  - name: web
    count: 3
images:
  - name: nginx
    newTag: 1.27-alpine
YAML

# Git Bash: kubectl.exe expects a Windows path
command -v cygpath >/dev/null 2>&1 && O=$(cygpath -m "$O")
kubectl kustomize "$O"
kubectl apply -k "$O"
kubectl rollout status deploy/prod-web -n ckad-18 --timeout=180s
