#!/usr/bin/env bash
# Solution — exercise 19
set -euo pipefail
NS=ckad-19
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"
F="$ANS/19-legacy.yaml"

kubectl api-resources | grep -Ei 'deploy|ingress|cronjob|horizontal'

cat > "$F" <<'YAML'
apiVersion: apps/v1                 # was apps/v1beta1
kind: Deployment
metadata:
  name: legacy-app
spec:
  replicas: 2
  selector:                         # now mandatory
    matchLabels:
      app: legacy-app
  template:
    metadata:
      labels:
        app: legacy-app
    spec:
      containers:
        - name: web
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: legacy-app
spec:
  selector:
    app: legacy-app
  ports:
    - port: 80
---
apiVersion: networking.k8s.io/v1    # was extensions/v1beta1
kind: Ingress
metadata:
  name: legacy-ing
spec:
  ingressClassName: nginx
  rules:
    - host: legacy.local
      http:
        paths:
          - path: /
            pathType: Prefix        # mandatory
            backend:
              service:              # new structure
                name: legacy-app
                port:
                  number: 80
---
apiVersion: batch/v1                # was batch/v1beta1
kind: CronJob
metadata:
  name: legacy-cron
spec:
  schedule: "0 3 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: backup
              image: busybox:1.36
              command: ["echo", "backup"]
---
apiVersion: autoscaling/v2          # was autoscaling/v2beta2 (same schema)
kind: HorizontalPodAutoscaler
metadata:
  name: legacy-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: legacy-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
YAML

kubectl apply -n "$NS" -f - < "$F"
kubectl rollout status deploy/legacy-app -n "$NS" --timeout=180s

kubectl api-resources --api-group=networking.k8s.io | awk '$NF=="Ingress" {print $3}' > "$ANS/19-ingress-api.txt"
cat "$ANS/19-ingress-api.txt"
