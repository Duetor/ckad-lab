#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-12
hist() { helm history shop -n "$NS" -o json 2>/dev/null; }

check "Release shop is deployed" \
  '[ "$(helm status shop -n $NS -o json 2>/dev/null | jq -r .info.status)" = deployed ]'
check "A broken upgrade (9.9-broken) was attempted" \
  'hist | jq -e "length >= 4"'
check "The last operation is a rollback to revision 2" \
  'hist | jq -e "last | .description == \"Rollback to 2\""'
check "Deployment shop-webapp: 2 available replicas running nginx:1.27-alpine" \
  '[ "$(jp deploy shop-webapp -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ] && [ "$(jp deploy shop-webapp -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "Service shop-webapp is of type NodePort" \
  '[ "$(jp svc shop-webapp -n $NS -o jsonpath={.spec.type})" = NodePort ]'
check "~/ckad-answers/12-values.yaml contains the release values" \
  'grep -q "replicaCount: 2" "$CKAD_ANSWERS_DIR/12-values.yaml" && grep -q "type: NodePort" "$CKAD_ANSWERS_DIR/12-values.yaml"'
check "~/ckad-answers/12-releases.txt lists the releases (with NAMESPACE)" \
  'grep -q "NAMESPACE" "$CKAD_ANSWERS_DIR/12-releases.txt" && grep -qE "^shop[[:space:]]+ckad-12" "$CKAD_ANSWERS_DIR/12-releases.txt"'

summary
