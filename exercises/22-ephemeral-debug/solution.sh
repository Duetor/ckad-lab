#!/usr/bin/env bash
# Solution — exercise 22
set -euo pipefail
NS=ckad-22
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# 1. Ephemeral container sharing the process namespace of "app".
#    Interactively you would run: kubectl debug -it locked --image=busybox:1.36 --target=app -- sh
#    then: cat /proc/1/root/etc/token/value
kubectl debug locked -n "$NS" -c dbg --image=busybox:1.36 --target=app \
  -- sh -c 'cat /proc/1/root/etc/token/value'
for _ in $(seq 1 30); do
  T=$(kubectl logs locked -n "$NS" -c dbg 2>/dev/null || true)
  [ -n "$T" ] && break
  sleep 2
done
echo "$T" > "$ANS/22-token.txt"
echo "Token: $T"

# 2. Copy of the pod with a shell container and shared processes
kubectl debug locked -n "$NS" --copy-to=locked-debug --share-processes \
  --container=shell --image=busybox:1.36 -- sleep 3600
kubectl wait -n "$NS" --for=condition=Ready pod/locked-debug --timeout=120s
