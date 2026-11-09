#!/usr/bin/env bash
# Solution — exercise 11
set -euo pipefail
NS=ckad-11

kubectl expose deploy app-a --name=svc-a --port=8080 --target-port=5678 -n "$NS"
kubectl expose deploy app-b --name=svc-b --port=8080 --target-port=5678 -n "$NS"

kubectl create ingress apps -n "$NS" --class=nginx \
  --rule="ckad.local/a*=svc-a:8080" \
  --rule="ckad.local/b*=svc-b:8080"

# The ingress controller takes a few seconds to pick up the config
sleep 10
curl -s --max-time 5 http://ckad.local/a || echo "(curl from the host not available here, in-cluster test via ckad check 11)"
