#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-08
SA="system:serviceaccount:$NS:monitor"
sc() { jp pod secure -n "$NS" -o jsonpath="{.spec$1}"; }

check "ServiceAccount monitor existe" 'jp sa monitor -n $NS'
check "monitor peut lister et watcher les pods" \
  '[ "$(kubectl auth can-i list pods --as=$SA -n $NS)" = yes ] && [ "$(kubectl auth can-i watch pods --as=$SA -n $NS)" = yes ]'
check "monitor ne peut PAS supprimer de pods ni lire les secrets" \
  '[ "$(kubectl auth can-i delete pods --as=$SA -n $NS)" = no ] && [ "$(kubectl auth can-i get secrets --as=$SA -n $NS)" = no ]'
check "RoleBinding monitor-binding -> Role pod-reader" \
  '[ "$(jp rolebinding monitor-binding -n $NS -o jsonpath="{.roleRef.kind}/{.roleRef.name}")" = Role/pod-reader ]'
check "Le pod secure est Running avec le SA monitor" \
  '[ "$(sc .serviceAccountName)" = monitor ] && [ "$(jp pod secure -n $NS -o jsonpath={.status.phase})" = Running ]'
check "Pod : runAsUser=1000, runAsGroup=3000" \
  '[ "$(sc .securityContext.runAsUser)/$(sc .securityContext.runAsGroup)" = 1000/3000 ] && [ "$(kx secure -n $NS -- id -u)" = 1000 ]'
check "Conteneur : allowPrivilegeEscalation=false, readOnlyRootFilesystem=true" \
  '[ "$(sc ".containers[0].securityContext.allowPrivilegeEscalation")/$(sc ".containers[0].securityContext.readOnlyRootFilesystem")" = false/true ]'
check "Conteneur : capabilities drop ALL" \
  '[ "$(sc ".containers[0].securityContext.capabilities.drop[*]")" = ALL ]'
check "Le système de fichiers racine est réellement en lecture seule" \
  '! kx secure -n $NS -- touch /test'

summary
