#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-01

check "Le pod logger existe et est Running" \
  '[ "$(jp pod logger -n $NS -o jsonpath={.status.phase})" = Running ]'
check "Il contient les conteneurs app et sidecar" \
  'n=$(jp pod logger -n $NS -o jsonpath="{.spec.containers[*].name} {.spec.initContainers[*].name}"); [[ " $n " == *" app "* && " $n " == *" sidecar "* ]]'
check "Les deux conteneurs utilisent busybox:1.36" \
  '[ "$(jp pod logger -n $NS -o jsonpath="{.spec.containers[*].image} {.spec.initContainers[*].image}" | tr " " "\n" | grep -c "^busybox:1.36$")" -ge 2 ]'
check "Le volume logs est de type emptyDir" \
  '[ -n "$(jp pod logger -n $NS -o jsonpath="{.spec.volumes[?(@.name==\"logs\")].emptyDir}")" ]'
check "logs est monté sur /var/log/app dans les deux conteneurs" \
  '[ "$(jp pod logger -n $NS -o json | jq "[(.spec.containers + (.spec.initContainers // []))[] | select(.volumeMounts[]? | .name==\"logs\" and .mountPath==\"/var/log/app\")] | length")" -ge 2 ]'
check "Le sidecar affiche des lignes de log" \
  '[ -n "$(kubectl logs logger -c sidecar -n $NS --tail=1 2>/dev/null)" ]'

summary
