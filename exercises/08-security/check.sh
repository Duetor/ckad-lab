#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-08
SA="system:serviceaccount:$NS:monitor"
sc() { jp pod secure -n "$NS" -o jsonpath="{.spec$1}"; }

check "ServiceAccount monitor exists" 'jp sa monitor -n $NS'
check "monitor can list and watch pods" \
  '[ "$(kubectl auth can-i list pods --as=$SA -n $NS)" = yes ] && [ "$(kubectl auth can-i watch pods --as=$SA -n $NS)" = yes ]'
check "monitor can NOT delete pods or read secrets" \
  '[ "$(kubectl auth can-i delete pods --as=$SA -n $NS)" = no ] && [ "$(kubectl auth can-i get secrets --as=$SA -n $NS)" = no ]'
check "RoleBinding monitor-binding -> Role pod-reader" \
  '[ "$(jp rolebinding monitor-binding -n $NS -o jsonpath="{.roleRef.kind}/{.roleRef.name}")" = Role/pod-reader ]'
check "Pod secure is Running with SA monitor" \
  '[ "$(sc .serviceAccountName)" = monitor ] && [ "$(jp pod secure -n $NS -o jsonpath={.status.phase})" = Running ]'
check "Pod: runAsUser=1000, runAsGroup=3000" \
  '[ "$(sc .securityContext.runAsUser)/$(sc .securityContext.runAsGroup)" = 1000/3000 ] && [ "$(kx secure -n $NS -- id -u)" = 1000 ]'
check "Container: allowPrivilegeEscalation=false, readOnlyRootFilesystem=true" \
  '[ "$(sc ".containers[0].securityContext.allowPrivilegeEscalation")/$(sc ".containers[0].securityContext.readOnlyRootFilesystem")" = false/true ]'
check "Container: capabilities drop ALL" \
  '[ "$(sc ".containers[0].securityContext.capabilities.drop[*]")" = ALL ]'
check "The root filesystem is really read-only" \
  '! kx secure -n $NS -- touch /test'

summary
