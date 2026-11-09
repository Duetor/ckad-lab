#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-16

check "~/ckad-answers/16-container.txt contains reader" \
  'grep -qx reader "$CKAD_ANSWERS_DIR/16-container.txt"'
check "~/ckad-answers/16-reason.txt contains Error" \
  'grep -qx Error "$CKAD_ANSWERS_DIR/16-reason.txt"'
check "Container commands are unchanged" \
  'jp pod report -n $NS -o jsonpath="{.spec.containers[*].command}" | grep -q "/out/report.txt" && jp pod report -n $NS -o jsonpath="{.spec.containers[*].command}" | grep -q "/in/report.txt"'
check "reader still mounts the shared volume at /in" \
  'jp pod report -n $NS -o json | jq -e ".spec.containers[] | select(.name==\"reader\") | .volumeMounts[] | select(.name==\"shared\" and .mountPath==\"/in\")"'
check "Pod report is Running and reader no longer restarts" \
  '[ "$(jp pod report -n $NS -o jsonpath={.status.phase})" = Running ] && [ "$(jp pod report -n $NS -o jsonpath="{.status.containerStatuses[?(@.name==\"reader\")].ready}")" = true ] && [ "$(jp pod report -n $NS -o jsonpath="{.status.containerStatuses[?(@.name==\"reader\")].restartCount}")" -le 1 ]'
check "reader displays the report lines" \
  'kubectl logs report -n $NS -c reader --tail=4 2>/dev/null | grep -q "report line"'

summary
