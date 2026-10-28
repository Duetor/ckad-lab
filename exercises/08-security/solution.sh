#!/usr/bin/env bash
# Solution — exercice 08
set -euo pipefail
NS=ckad-08

kubectl create sa monitor -n "$NS"
kubectl create role pod-reader -n "$NS" --verb=get,list,watch --resource=pods
kubectl create rolebinding monitor-binding -n "$NS" --role=pod-reader --serviceaccount="$NS:monitor"

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: secure
spec:
  serviceAccountName: monitor
  securityContext:          # niveau pod
    runAsUser: 1000
    runAsGroup: 3000
  containers:
    - name: secure
      image: busybox:1.36
      command: ["sleep", "3600"]
      securityContext:      # niveau conteneur
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
YAML
kubectl wait -n "$NS" --for=condition=Ready pod/secure --timeout=120s

kubectl auth can-i list pods   --as="system:serviceaccount:$NS:monitor" -n "$NS"   # yes
kubectl auth can-i delete pods --as="system:serviceaccount:$NS:monitor" -n "$NS" || true  # no
