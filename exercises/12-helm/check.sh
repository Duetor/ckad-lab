#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-12
hist() { helm history shop -n "$NS" -o json 2>/dev/null; }

check "La release shop est deployed" \
  '[ "$(helm status shop -n $NS -o json 2>/dev/null | jq -r .info.status)" = deployed ]'
check "Un upgrade cassé (9.9-broken) a été tenté" \
  'hist | jq -e "length >= 4"'
check "La dernière opération est un rollback vers la révision 2" \
  'hist | jq -e "last | .description == \"Rollback to 2\""'
check "Deployment shop-webapp : 2 réplicas disponibles en nginx:1.27-alpine" \
  '[ "$(jp deploy shop-webapp -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ] && [ "$(jp deploy shop-webapp -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "Service shop-webapp de type NodePort" \
  '[ "$(jp svc shop-webapp -n $NS -o jsonpath={.spec.type})" = NodePort ]'
check "~/ckad-answers/12-values.yaml contient les valeurs de la release" \
  'grep -q "replicaCount: 2" "$CKAD_ANSWERS_DIR/12-values.yaml" && grep -q "type: NodePort" "$CKAD_ANSWERS_DIR/12-values.yaml"'
check "~/ckad-answers/12-releases.txt liste les releases (avec NAMESPACE)" \
  'grep -q "NAMESPACE" "$CKAD_ANSWERS_DIR/12-releases.txt" && grep -qE "^shop[[:space:]]+ckad-12" "$CKAD_ANSWERS_DIR/12-releases.txt"'

summary
