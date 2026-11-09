#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-19
F="$CKAD_ANSWERS_DIR/19-legacy.yaml"

check "The file no longer contains deprecated APIs" \
  '[ -s "$F" ] && ! grep -Eq "apiVersion: *(apps/v1beta[12]|extensions/v1beta1|batch/v1beta1|autoscaling/v2beta[12])" "$F"'
check "Deployment legacy-app: 2 available replicas" \
  '[ "$(jp deploy legacy-app -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "Ingress legacy-ing: legacy.local / → legacy-app:80" \
  'jp ingress legacy-ing -n $NS -o json | jq -e ".spec.rules[0] | .host==\"legacy.local\" and .http.paths[0].path==\"/\" and .http.paths[0].backend.service.name==\"legacy-app\" and .http.paths[0].backend.service.port.number==80"'
check "CronJob legacy-cron scheduled at 0 3 * * *" \
  '[ "$(jp cronjob legacy-cron -n $NS -o jsonpath={.spec.schedule})" = "0 3 * * *" ]'
check "HPA legacy-hpa: 2-5 replicas, CPU 70%" \
  'jp hpa legacy-hpa -n $NS -o json | jq -e ".spec.minReplicas==2 and .spec.maxReplicas==5 and .spec.metrics[0].resource.target.averageUtilization==70"'
check "~/ckad-answers/19-ingress-api.txt contains networking.k8s.io/v1" \
  'grep -qx "networking.k8s.io/v1" "$CKAD_ANSWERS_DIR/19-ingress-api.txt"'

summary
