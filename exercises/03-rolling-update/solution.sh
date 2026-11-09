#!/usr/bin/env bash
# Solution — exercise 03
set -euo pipefail
NS=ckad-03
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# Diagnosis: pods of the latest revision are in ImagePullBackOff
kubectl get pods -n "$NS"
kubectl rollout history deploy/web -n "$NS"

# 1. Image of revision 1
kubectl rollout history deploy/web -n "$NS" --revision=1 \
  | awk '/Image:/ {print $2}' > "$ANS/03-revision1.txt"

# 2. Roll back to the previous revision (2, nginx:1.27-alpine)
kubectl rollout undo deploy/web -n "$NS"
kubectl rollout status deploy/web -n "$NS" --timeout=180s

# 3. Strategy
kubectl patch deploy web -n "$NS" \
  -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'

# 4. Scale
kubectl scale deploy web -n "$NS" --replicas=4
kubectl rollout status deploy/web -n "$NS" --timeout=180s

# 5. Annotation
kubectl annotate deploy web -n "$NS" kubernetes.io/change-cause="rollback after broken release" --overwrite
