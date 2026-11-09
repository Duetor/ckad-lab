#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-22
TOKEN=$(jp secret app-token -n "$NS" -o jsonpath='{.data.value}' | base64 -d)

check "An ephemeral container was added to pod locked" \
  '[ -n "$(jp pod locked -n $NS -o jsonpath="{.spec.ephemeralContainers[*].name}")" ]'
check "That ephemeral container targets container app" \
  'jp pod locked -n $NS -o jsonpath="{.spec.ephemeralContainers[*].targetContainerName}" | grep -qw app'
check "~/ckad-answers/22-token.txt contains the right token" \
  '[ -n "$TOKEN" ] && [ "$(tr -d "\r\n " < "$CKAD_ANSWERS_DIR/22-token.txt")" = "$TOKEN" ]'
check "Pod locked is still running" \
  '[ "$(jp pod locked -n $NS -o jsonpath={.status.phase})" = Running ]'
check "Pod locked-debug: shareProcessNamespace enabled" \
  '[ "$(jp pod locked-debug -n $NS -o jsonpath={.spec.shareProcessNamespace})" = true ]'
check "locked-debug runs app (pause) and shell (busybox:1.36)" \
  '[ "$(jp pod locked-debug -n $NS -o jsonpath="{.spec.containers[?(@.name==\"shell\")].image}")" = busybox:1.36 ] && [ "$(jp pod locked-debug -n $NS -o jsonpath="{.spec.containers[?(@.name==\"app\")].image}")" = registry.k8s.io/pause:3.10 ] && [ "$(jp pod locked-debug -n $NS -o jsonpath={.status.phase})" = Running ]'

summary
