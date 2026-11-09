#!/usr/bin/env bash
# Solution — exercise 17
set -euo pipefail
NS=ckad-17
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: standard
  resources:
    requests:
      storage: 256Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
spec:
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data-pvc
  containers:
    - name: writer
      image: busybox:1.36
      command: ["sh", "-c", "echo persisted-$(hostname) > /data/state.txt && sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/writer --timeout=120s
sleep 2
kubectl delete pod writer -n "$NS" --force --grace-period=0

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: reader
spec:
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data-pvc
  containers:
    - name: reader
      image: busybox:1.36
      command: ["sleep", "3600"]
      volumeMounts:
        - name: data
          mountPath: /data
          readOnly: true
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/reader --timeout=120s
kubectl exec reader -n "$NS" -- cat /data/state.txt

kubectl get pvc data-pvc -n "$NS" -o jsonpath='{.spec.volumeName}' > "$ANS/17-pv.txt"
