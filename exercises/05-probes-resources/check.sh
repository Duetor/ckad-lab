#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-05
C='.spec.template.spec.containers[0]'
c() { jp deploy api -n "$NS" -o jsonpath="{$C$1}"; }

check "Deployment api : 2 réplicas disponibles en nginx:1.27-alpine" \
  '[ "$(c .image)" = nginx:1.27-alpine ] && [ "$(jp deploy api -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "readinessProbe httpGet / :80 (delay 5, period 10)" \
  '[ "$(c .readinessProbe.httpGet.path)|$(c .readinessProbe.httpGet.port)|$(c .readinessProbe.initialDelaySeconds)|$(c .readinessProbe.periodSeconds)" = "/|80|5|10" ]'
check "livenessProbe tcpSocket :80 (period 15, failureThreshold 3)" \
  '[ "$(c .livenessProbe.tcpSocket.port)|$(c .livenessProbe.periodSeconds)|$(c .livenessProbe.failureThreshold)" = "80|15|3" ]'
check "startupProbe httpGet / :80 (failureThreshold 30, period 2)" \
  '[ "$(c .startupProbe.httpGet.path)|$(c .startupProbe.httpGet.port)|$(c .startupProbe.failureThreshold)|$(c .startupProbe.periodSeconds)" = "/|80|30|2" ]'
check "requests cpu=100m memory=64Mi" \
  '[ "$(c .resources.requests.cpu)|$(c .resources.requests.memory)" = "100m|64Mi" ]'
check "limits cpu=250m memory=128Mi" \
  '[ "$(c .resources.limits.cpu)|$(c .resources.limits.memory)" = "250m|128Mi" ]'
check "~/ckad-answers/05-top.txt contient la sortie de kubectl top" \
  'grep -q "^api-" "$CKAD_ANSWERS_DIR/05-top.txt" && grep -q "CPU" "$CKAD_ANSWERS_DIR/05-top.txt"'

summary
