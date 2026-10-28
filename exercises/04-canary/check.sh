#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-04

check "shop-v1 a toujours 4 réplicas" \
  '[ "$(jp deploy shop-v1 -n $NS -o jsonpath={.spec.replicas})" = 4 ]'
check "shop-v2 existe avec l'image nginx:1.27-alpine" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ]'
check "Les pods de shop-v2 ont les labels app=shop et version=v2" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath="{.spec.template.metadata.labels.app}/{.spec.template.metadata.labels.version}")" = shop/v2 ]'
check "shop-v2 a 1 réplica disponible (20 %)" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath={.spec.replicas})" = 1 ] && [ "$(jp deploy shop-v2 -n $NS -o jsonpath={.status.availableReplicas})" = 1 ]'
check "Le Service shop sélectionne app=shop sans filtrer la version" \
  '[ "$(jp svc shop -n $NS -o jsonpath={.spec.selector.app})" = shop ] && [ -z "$(jp svc shop -n $NS -o jsonpath={.spec.selector.version})" ]'
check "Le Service shop a 5 endpoints prêts" \
  '[ "$(jp endpointslices -n $NS -l kubernetes.io/service-name=shop -o json | jq "[.items[].endpoints[]? | select(.conditions.ready)] | length")" = 5 ]'

summary
