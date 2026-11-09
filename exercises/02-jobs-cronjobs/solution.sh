#!/usr/bin/env bash
# Solution — exercise 02
set -euo pipefail
NS=ckad-02

# 1. Job: generate the skeleton, then complete it
kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: batch/v1
kind: Job
metadata:
  name: countdown
spec:
  completions: 3
  parallelism: 2
  backoffLimit: 4
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: countdown
          image: busybox:1.36
          command: ["sh", "-c", "for i in 3 2 1; do echo $i; sleep 1; done; echo liftoff"]
YAML
kubectl wait -n "$NS" --for=condition=complete job/countdown --timeout=180s

# 2. CronJob
kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup
spec:
  schedule: "*/15 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      activeDeadlineSeconds: 30
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: cleanup
              image: busybox:1.36
              command: ["echo", "cleanup done"]
YAML

# 3. Manual trigger
kubectl create job cleanup-manual --from=cronjob/cleanup -n "$NS"
