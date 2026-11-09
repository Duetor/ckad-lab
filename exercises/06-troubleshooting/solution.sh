#!/usr/bin/env bash
# Solution — exercise 06
set -euo pipefail
NS=ckad-06
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# 3. (first, while the Warnings are recent) the events
for _ in $(seq 1 20); do
  kubectl get events -n "$NS" --field-selector type=Warning --sort-by=.lastTimestamp > "$ANS/06-events.txt"
  grep -q Warning "$ANS/06-events.txt" && break
  sleep 3
done

# 1a. Misspelled image (ngnix) -> ImagePullBackOff
kubectl set image deploy/backend web=nginx:1.27-alpine -n "$NS"
# 1b. Wrong Service selector (tier=backnd) -> no endpoints
kubectl patch svc backend -n "$NS" -p '{"spec":{"selector":{"app":"backend","tier":"api"}}}'
# 1c. targetPort 8080 while nginx listens on 80
kubectl patch svc backend -n "$NS" --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
kubectl rollout status deploy/backend -n "$NS" --timeout=180s

# 2. Error message of the worker
for _ in $(seq 1 20); do
  kubectl logs worker -n "$NS" 2>/dev/null | grep FATAL > "$ANS/06-worker-error.txt" && break
  kubectl logs worker -n "$NS" --previous 2>/dev/null | grep FATAL > "$ANS/06-worker-error.txt" && break
  sleep 3
done

# 2. Recreate the pod with the environment variable
kubectl get pod worker -n "$NS" -o json \
  | jq '.spec.containers[0].env = [{"name":"DB_HOST","value":"postgres.ckad-06.svc"}]
        | del(.status, .metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp)' \
  | kubectl replace --force -f -
kubectl wait -n "$NS" --for=condition=Ready pod/worker --timeout=120s
