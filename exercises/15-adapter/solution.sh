#!/usr/bin/env bash
# Solution — exercise 15
set -euo pipefail
NS=ckad-15

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: metrics
spec:
  volumes:
    - name: data
      emptyDir:
        sizeLimit: 50Mi
  containers:
    - name: app
      image: busybox:1.36
      command:
        - sh
        - -c
        - while true; do echo "cpu=$((RANDOM % 100)) mem=512" >> /data/raw.log; sleep 2; done
      resources:
        limits: {memory: 32Mi}
      volumeMounts:
        - name: data
          mountPath: /data
    - name: adapter
      image: busybox:1.36
      command:
        - sh
        - -c
        - tail -n+1 -F /data/raw.log | awk '{print "METRIC", $0; fflush()}'
      resources:
        limits: {memory: 32Mi}
      volumeMounts:
        - name: data
          mountPath: /data
          readOnly: true
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/metrics --timeout=120s
sleep 6
kubectl logs metrics -n "$NS" -c adapter --tail=3
