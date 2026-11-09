#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-16
fresh_ns "$NS"
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: report
spec:
  volumes:
    - name: shared
      emptyDir: {}
  containers:
    - name: writer
      image: busybox:1.36
      command: ["sh", "-c", "mkdir -p /out; i=0; while true; do i=$((i+1)); echo \"report line $i\" >> /out/report.txt; sleep 2; done"]
      volumeMounts:
        - name: shared
          mountPath: /data
    - name: reader
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3; while true; do tail -n 2 /in/report.txt || exit 1; sleep 5; done"]
      volumeMounts:
        - name: shared
          mountPath: /in
YAML
