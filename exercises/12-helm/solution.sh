#!/usr/bin/env bash
# Solution — exercice 12
set -euo pipefail
NS=ckad-12
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"
CHART="${CKAD_LAB_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}/exercises/12-helm/chart/webapp"

helm show values "$CHART"
helm install shop "$CHART" -n "$NS" --set replicaCount=2,image.tag=1.27-alpine --wait
helm upgrade shop "$CHART" -n "$NS" --reuse-values --set service.type=NodePort --wait

# Upgrade cassé (sans --wait, sinon on attend le timeout)
helm upgrade shop "$CHART" -n "$NS" --reuse-values --set image.tag=9.9-broken
sleep 5
kubectl get pods -n "$NS"          # ImagePullBackOff
helm history shop -n "$NS"
helm rollback shop 2 -n "$NS" --wait

helm get values shop -n "$NS" > "$ANS/12-values.yaml"
helm list -A > "$ANS/12-releases.txt"
