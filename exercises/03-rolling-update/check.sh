#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-03

check "~/ckad-answers/03-revision1.txt contient nginx:1.25-alpine" \
  'grep -qx "nginx:1.25-alpine" "$CKAD_ANSWERS_DIR/03-revision1.txt"'
check "Le Deployment utilise de nouveau nginx:1.27-alpine" \
  '[ "$(jp deploy web -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ]'
check "Il s'agit d'un rollback (révision >= 4), pas d'une recréation" \
  '[ "$(jp deploy web -n $NS -o jsonpath="{.metadata.annotations.deployment\.kubernetes\.io/revision}")" -ge 4 ]'
check "Stratégie RollingUpdate maxSurge=1 / maxUnavailable=0" \
  '[ "$(jp deploy web -n $NS -o jsonpath="{.spec.strategy.rollingUpdate.maxSurge}/{.spec.strategy.rollingUpdate.maxUnavailable}")" = "1/0" ]'
check "4 réplicas disponibles" \
  '[ "$(jp deploy web -n $NS -o jsonpath={.spec.replicas})" = 4 ] && [ "$(jp deploy web -n $NS -o jsonpath={.status.availableReplicas})" = 4 ]'
check "Annotation change-cause positionnée" \
  '[ "$(jp deploy web -n $NS -o jsonpath="{.metadata.annotations.kubernetes\.io/change-cause}")" = "rollback after broken release" ]'

summary
