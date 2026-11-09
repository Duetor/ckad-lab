#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-04

check "shop-v1 still has 4 replicas" \
  '[ "$(jp deploy shop-v1 -n $NS -o jsonpath={.spec.replicas})" = 4 ]'
check "shop-v2 exists with image nginx:1.27-alpine" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ]'
check "shop-v2 pods have labels app=shop and version=v2" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath="{.spec.template.metadata.labels.app}/{.spec.template.metadata.labels.version}")" = shop/v2 ]'
check "shop-v2 has 1 available replica (20%)" \
  '[ "$(jp deploy shop-v2 -n $NS -o jsonpath={.spec.replicas})" = 1 ] && [ "$(jp deploy shop-v2 -n $NS -o jsonpath={.status.availableReplicas})" = 1 ]'
check "Service shop selects app=shop without filtering on version" \
  '[ "$(jp svc shop -n $NS -o jsonpath={.spec.selector.app})" = shop ] && [ -z "$(jp svc shop -n $NS -o jsonpath={.spec.selector.version})" ]'
check "Service shop has 5 ready endpoints" \
  '[ "$(jp endpointslices -n $NS -l kubernetes.io/service-name=shop -o json | jq "[.items[].endpoints[]? | select(.conditions.ready)] | length")" = 5 ]'

summary
