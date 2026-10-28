#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-09
q() { jp quota team-quota -n "$NS" -o jsonpath="{.spec.hard.$1}"; }
lr() { jp limitrange defaults -n "$NS" -o jsonpath="{.spec.limits[?(@.type==\"Container\")].$1}"; }

check "Quota requests.cpu=1, requests.memory=1Gi" \
  '[ "$(q "requests\.cpu")/$(q "requests\.memory")" = 1/1Gi ]'
check "Quota limits.cpu=2, limits.memory=2Gi, pods=5" \
  '[ "$(q "limits\.cpu")/$(q "limits\.memory")/$(q pods)" = 2/2Gi/5 ]'
check "LimitRange defaultRequest cpu=100m memory=128Mi" \
  '[ "$(lr defaultRequest.cpu)/$(lr defaultRequest.memory)" = 100m/128Mi ]'
check "LimitRange default cpu=200m memory=256Mi" \
  '[ "$(lr default.cpu)/$(lr default.memory)" = 200m/256Mi ]'
check "Deployment worker : 3 réplicas disponibles, sans ressources dans le template" \
  '[ "$(jp deploy worker -n $NS -o jsonpath={.status.availableReplicas})" = 3 ] && [ "$(jp deploy worker -n $NS -o json | jq -c ".spec.template.spec.containers[0].resources // {}")" = "{}" ]'
check "Les pods worker ont hérité de la LimitRange" \
  '[ "$(jp pods -n $NS -o json | jq -r "[.items[] | select(.metadata.name | startswith(\"worker-\"))][0].spec.containers[0].resources.requests.memory")" = 128Mi ]'
check "Le pod big n'existe pas" '! jp pod big -n $NS'
check "~/ckad-answers/09-quota-error.txt contient l'erreur de quota" \
  'grep -qi "exceeded quota" "$CKAD_ANSWERS_DIR/09-quota-error.txt"'

summary
