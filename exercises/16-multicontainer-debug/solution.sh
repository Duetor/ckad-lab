#!/usr/bin/env bash
# Solution — exercise 16
set -euo pipefail
NS=ckad-16
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# Diagnosis: reader restarts (tail fails: the file is not in the volume)
for _ in $(seq 1 30); do
  R=$(kubectl get pod report -n "$NS" -o jsonpath='{.status.containerStatuses[?(@.name=="reader")].lastState.terminated.reason}')
  [ -n "$R" ] && break
  sleep 3
done
echo reader > "$ANS/16-container.txt"
echo "$R"   > "$ANS/16-reason.txt"          # Error (exit code 1)

# Fix: writer writes to /out, but the shared volume is mounted at /data in writer.
# So we mount the volume at /out in writer (commands unchanged).
kubectl get pod report -n "$NS" -o json \
  | jq '(.spec.containers[] | select(.name=="writer") | .volumeMounts[] | select(.name=="shared")).mountPath = "/out"
        | del(.status, .metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp)' \
  | kubectl replace --force -f -
kubectl wait -n "$NS" --for=condition=Ready pod/report --timeout=120s
sleep 8
kubectl logs report -n "$NS" -c reader --tail=2
