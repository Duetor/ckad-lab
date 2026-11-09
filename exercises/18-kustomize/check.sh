#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-18
K="$CKAD_ANSWERS_DIR/18-kustomize"
BASE="$(dirname "$0")/files/base"

check "Overlay overlays/prod/kustomization.yaml exists and references the base" \
  'grep -Eq "\.\./\.\./base" "$K/overlays/prod/kustomization.yaml"'
check "The base was not modified" \
  'diff -r "$BASE" "$K/base"'
check "Deployment prod-web in ckad-18: 3 available replicas" \
  '[ "$(jp deploy prod-web -n $NS -o jsonpath={.spec.replicas})" = 3 ] && [ "$(jp deploy prod-web -n $NS -o jsonpath={.status.availableReplicas})" = 3 ]'
check "Image nginx:1.27-alpine" \
  '[ "$(jp deploy prod-web -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}")" = nginx:1.27-alpine ]'
check "Label env=prod on the Deployment, its pods and its selector" \
  '[ "$(jp deploy prod-web -n $NS -o jsonpath="{.metadata.labels.env}/{.spec.selector.matchLabels.env}/{.spec.template.metadata.labels.env}")" = prod/prod/prod ]'
check "Service prod-web (selector env=prod) has 3 endpoints" \
  '[ "$(jp svc prod-web -n $NS -o jsonpath={.spec.selector.env})" = prod ] && [ "$(jp endpointslices -n $NS -l kubernetes.io/service-name=prod-web -o json | jq "[.items[].endpoints[]? | select(.conditions.ready)] | length")" = 3 ]'

summary
