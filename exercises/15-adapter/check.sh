#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-15
p() { jp pod metrics -n "$NS" -o jsonpath="{.spec$1}"; }

check "Pod metrics is Running with containers app and adapter" \
  '[ "$(jp pod metrics -n $NS -o jsonpath={.status.phase})" = Running ] && [ "$(p ".containers[*].name" | tr " " "\n" | sort | xargs)" = "adapter app" ]'
check "Volume data: emptyDir with sizeLimit 50Mi" \
  '[ "$(p ".volumes[?(@.name==\"data\")].emptyDir.sizeLimit")" = 50Mi ]'
check "data mounted at /data in app (read-write) and adapter (read-only)" \
  'j=$(jp pod metrics -n $NS -o json); echo "$j" | jq -e ".spec.containers[] | select(.name==\"adapter\") | .volumeMounts[] | select(.name==\"data\" and .mountPath==\"/data\") | .readOnly == true" && echo "$j" | jq -e ".spec.containers[] | select(.name==\"app\") | .volumeMounts[] | select(.name==\"data\" and .mountPath==\"/data\") | (.readOnly // false) == false"'
check "Memory limit 32Mi on both containers" \
  '[ "$(p ".containers[*].resources.limits.memory")" = "32Mi 32Mi" ]'
check "The adapter outputs METRIC cpu=... lines" \
  'kubectl logs metrics -n $NS -c adapter --tail=5 2>/dev/null | grep -Eq "^METRIC cpu=[0-9]+ mem=512$"'

summary
