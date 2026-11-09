#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-13

check "Pod web-init is Running with label app=web-init" \
  '[ "$(jp pod web-init -n $NS -o jsonpath="{.status.phase}/{.metadata.labels.app}")" = Running/web-init ]'
check "Init container fetch (busybox:1.36)" \
  '[ "$(jp pod web-init -n $NS -o jsonpath="{.spec.initContainers[?(@.name==\"fetch\")].image}")" = busybox:1.36 ]'
check "Main container web (nginx:1.27-alpine)" \
  '[ "$(jp pod web-init -n $NS -o jsonpath="{.spec.containers[?(@.name==\"web\")].image}")" = nginx:1.27-alpine ]'
check "Volume html is an emptyDir" \
  '[ -n "$(jp pod web-init -n $NS -o jsonpath="{.spec.volumes[?(@.name==\"html\")].emptyDir}")" ]'
check "html mounted at /work (fetch) and /usr/share/nginx/html (web)" \
  'j=$(jp pod web-init -n $NS -o json); echo "$j" | jq -e ".spec.initContainers[] | select(.name==\"fetch\") | .volumeMounts[] | select(.name==\"html\" and .mountPath==\"/work\")" && echo "$j" | jq -e ".spec.containers[] | select(.name==\"web\") | .volumeMounts[] | select(.name==\"html\" and .mountPath==\"/usr/share/nginx/html\")"'
check "nginx serves \"Hello from init\"" \
  '[ "$(kx web-init -n $NS -c web -- wget -qO- localhost)" = "Hello from init" ]'
check "Service web-init (port 80) has an endpoint" \
  'http_from $NS http://web-init | grep -q "Hello from init"'

summary
