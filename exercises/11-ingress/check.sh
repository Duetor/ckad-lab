#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-11
ING=http://ingress-nginx-controller.ingress-nginx.svc.cluster.local
via_ingress() {
  kubectl run "probe-$RANDOM" -n "$NS" --rm -i --restart=Never --quiet --image=busybox:1.36 --command -- \
    wget -qO- -T 5 --header "Host: ckad.local" "$ING$1" 2>/dev/null
}
svc_ok() {
  [ "$(jp svc "$1" -n "$NS" -o jsonpath="{.spec.type}/{.spec.ports[0].port}/{.spec.ports[0].targetPort}")" = "ClusterIP/8080/5678" ]
}
rule() { jp ingress apps -n "$NS" -o json | jq -e --arg p "$1" --arg s "$2" \
  '.spec.rules[] | select(.host=="ckad.local") | .http.paths[] | select(.path==$p and .pathType=="Prefix" and .backend.service.name==$s and .backend.service.port.number==8080)'; }

check "svc-a : ClusterIP 8080 → 5678"  'svc_ok svc-a'
check "svc-b : ClusterIP 8080 → 5678"  'svc_ok svc-b'
check "svc-a répond Hello from A"       'http_from $NS http://svc-a:8080 | grep -q "Hello from A"'
check "Ingress apps : ingressClassName nginx" \
  '[ "$(jp ingress apps -n $NS -o jsonpath={.spec.ingressClassName})" = nginx ]'
check "Règle ckad.local/a (Prefix) → svc-a:8080" 'rule /a svc-a'
check "Règle ckad.local/b (Prefix) → svc-b:8080" 'rule /b svc-b'
check "http://ckad.local/a répond via l'ingress" 'via_ingress /a | grep -q "Hello from A"'
check "http://ckad.local/b répond via l'ingress" 'via_ingress /b | grep -q "Hello from B"'

summary
