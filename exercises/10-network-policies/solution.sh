#!/usr/bin/env bash
# Solution — exercise 10
set -euo pipefail
NS=ckad-10

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels: {role: backend}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels: {role: frontend}
      ports:
        - protocol: TCP
          port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
spec:
  podSelector:
    matchLabels: {role: db}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels: {role: backend}
      ports:
        - protocol: TCP
          port: 80
YAML
sleep 5   # the CNI (Calico) applies the rules within a few seconds
kubectl exec frontend -n "$NS" -- wget -qO- -T 3 http://backend | head -4
