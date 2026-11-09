#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-01

check "Pod logger exists and is Running" \
  '[ "$(jp pod logger -n $NS -o jsonpath={.status.phase})" = Running ]'
check "It has the containers app and sidecar" \
  'n=$(jp pod logger -n $NS -o jsonpath="{.spec.containers[*].name} {.spec.initContainers[*].name}"); [[ " $n " == *" app "* && " $n " == *" sidecar "* ]]'
check "Both containers use busybox:1.36" \
  '[ "$(jp pod logger -n $NS -o jsonpath="{.spec.containers[*].image} {.spec.initContainers[*].image}" | tr " " "\n" | grep -c "^busybox:1.36$")" -ge 2 ]'
check "Volume logs is an emptyDir" \
  '[ -n "$(jp pod logger -n $NS -o jsonpath="{.spec.volumes[?(@.name==\"logs\")].emptyDir}")" ]'
check "logs is mounted at /var/log/app in both containers" \
  '[ "$(jp pod logger -n $NS -o json | jq "[(.spec.containers + (.spec.initContainers // []))[] | select(.volumeMounts[]? | .name==\"logs\" and .mountPath==\"/var/log/app\")] | length")" -ge 2 ]'
check "The sidecar prints log lines" \
  '[ -n "$(kubectl logs logger -c sidecar -n $NS --tail=1 2>/dev/null)" ]'

summary
