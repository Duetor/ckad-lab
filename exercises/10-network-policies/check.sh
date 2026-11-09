#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-10
can() { kx "$1" -n "$NS" -- wget -qO- -T 3 "http://$2" | grep -qi nginx; }

check "Pod labels unchanged" \
  '[ "$(jp pods -n $NS -o jsonpath="{range .items[*]}{.metadata.name}={.metadata.labels.role} {end}")" = "backend=backend db=db frontend=frontend intruder=other " ]'
check "NetworkPolicy default-deny: all pods, Ingress" \
  '[ "$(jp netpol default-deny -n $NS -o json | jq -c "[.spec.podSelector, .spec.policyTypes, (.spec.ingress // [])]")" = "[{},[\"Ingress\"],[]]" ]'
check "NetworkPolicies allow-frontend-to-backend and allow-backend-to-db exist" \
  'jp netpol allow-frontend-to-backend -n $NS && jp netpol allow-backend-to-db -n $NS'
check "frontend → backend: allowed" 'can frontend backend'
check "backend → db: allowed"       'can backend db'
check "frontend → db: blocked"        '! can frontend db'
check "intruder → backend: blocked"   '! can intruder backend'
check "intruder → db: blocked"        '! can intruder db'

summary
