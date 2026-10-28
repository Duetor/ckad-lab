#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-03
fresh_ns "$NS"
kubectl create deployment web --image=nginx:1.25-alpine --replicas=3 -n "$NS" >/dev/null
kubectl rollout status deploy/web -n "$NS" --timeout=180s >/dev/null
kubectl set image deploy/web nginx=nginx:1.27-alpine -n "$NS" >/dev/null
kubectl rollout status deploy/web -n "$NS" --timeout=180s >/dev/null
kubectl set image deploy/web nginx=nginx:1.27-alpine-oops -n "$NS" >/dev/null
