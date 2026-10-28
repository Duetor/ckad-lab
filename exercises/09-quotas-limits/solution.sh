#!/usr/bin/env bash
# Solution — exercice 09
set -euo pipefail
NS=ckad-09
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

kubectl create quota team-quota -n "$NS" \
  --hard=requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi,pods=5

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: LimitRange
metadata:
  name: defaults
spec:
  limits:
    - type: Container
      defaultRequest: {cpu: 100m, memory: 128Mi}
      default: {cpu: 200m, memory: 256Mi}
YAML

# Avec une quota sur les ressources, un pod sans requests/limits serait REFUSÉ…
# … sauf si une LimitRange fournit des valeurs par défaut (d'où l'ordre).
kubectl create deploy worker -n "$NS" --image=busybox:1.36 --replicas=3 -- sleep 3600
kubectl rollout status deploy/worker -n "$NS" --timeout=120s

kubectl apply -n "$NS" -f - 2> "$ANS/09-quota-error.txt" <<'YAML' || true
apiVersion: v1
kind: Pod
metadata:
  name: big
spec:
  containers:
    - name: big
      image: busybox:1.36
      command: ["sleep", "3600"]
      resources:
        requests: {memory: 2Gi}
        limits: {memory: 2Gi}
YAML
cat "$ANS/09-quota-error.txt"
kubectl describe quota team-quota -n "$NS"
