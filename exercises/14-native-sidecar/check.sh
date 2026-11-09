#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-14
d() { jp deploy api -n "$NS" -o jsonpath="{.spec.template.spec$1}"; }
POD=$(jp pods -n "$NS" -l app=api --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')

check "Deployment api: 2 available replicas" \
  '[ "$(jp deploy api -n $NS -o jsonpath={.status.availableReplicas})" = 2 ]'
check "log-shipper is a native sidecar (initContainer, restartPolicy Always)" \
  '[ "$(d ".initContainers[?(@.name==\"log-shipper\")].restartPolicy")" = Always ]'
check "log-shipper: image busybox:1.36, requests cpu=10m memory=16Mi" \
  '[ "$(d ".initContainers[?(@.name==\"log-shipper\")].image")" = busybox:1.36 ] && [ "$(d ".initContainers[?(@.name==\"log-shipper\")].resources.requests.cpu")/$(d ".initContainers[?(@.name==\"log-shipper\")].resources.requests.memory")" = 10m/16Mi ]'
check "Volume logs (emptyDir) mounted at /var/log/nginx in nginx" \
  'jp deploy api -n $NS -o json | jq -e ".spec.template.spec | (.volumes[] | select(.name==\"logs\") | .emptyDir) and ([.containers[] | select(.name==\"nginx\") | .volumeMounts[] | select(.name==\"logs\" and .mountPath==\"/var/log/nginx\")] | length == 1)"'
check "logs mounted read-only in log-shipper" \
  'jp deploy api -n $NS -o json | jq -e ".spec.template.spec.initContainers[] | select(.name==\"log-shipper\") | .volumeMounts[] | select(.name==\"logs\" and .mountPath==\"/var/log/nginx\") | .readOnly == true"'
check "The sidecar shows the requests received by nginx" \
  'kx "$POD" -n $NS -c nginx -- wget -qO- localhost >/dev/null; sleep 2; kubectl logs "$POD" -n $NS -c log-shipper 2>/dev/null | grep -q "GET /"'

summary
