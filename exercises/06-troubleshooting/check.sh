#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-06

check "Deployment backend : 2 réplicas disponibles" \
  '[ "$(jp deploy backend -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "Le Service backend a des endpoints" \
  '[ "$(jp endpointslices -n $NS -l kubernetes.io/service-name=backend -o json | jq "[.items[].endpoints[]? | select(.conditions.ready)] | length")" -ge 1 ]'
check "Le Service backend répond en HTTP sur le port 80" \
  'http_from $NS http://backend | grep -qi "welcome to nginx"'
check "~/ckad-answers/06-worker-error.txt contient le message d'erreur" \
  'grep -qx "FATAL: environment variable DB_HOST is not set" "$CKAD_ANSWERS_DIR/06-worker-error.txt"'
check "Le pod worker est Running avec DB_HOST=postgres.ckad-06.svc" \
  '[ "$(jp pod worker -n $NS -o jsonpath={.status.phase})" = Running ] && [ "$(kx worker -n $NS -- printenv DB_HOST)" = postgres.ckad-06.svc ]'
check "~/ckad-answers/06-events.txt contient les événements Warning" \
  'grep -q "Warning" "$CKAD_ANSWERS_DIR/06-events.txt" && ! grep -q "Normal" "$CKAD_ANSWERS_DIR/06-events.txt"'

summary
