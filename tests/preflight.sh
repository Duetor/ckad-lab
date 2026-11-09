#!/usr/bin/env bash
# Checks that this machine and the current cluster (kubectl context) are ready for the exercises.
# Works on Linux, WSL and Git Bash (Windows).
export MSYS_NO_PATHCONV=1
ok=0; ko=0
if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; N=$'\e[0m'; else G=; R=; Y=; N=; fi
pass() { printf '  %s✔%s %s\n' "$G" "$N" "$1"; ok=$((ok+1)); }
fail() { printf '  %s✘%s %s\n     → %s\n' "$R" "$N" "$1" "$2"; ko=$((ko+1)); }
warn() { printf '  %s!%s %s\n     → %s\n' "$Y" "$N" "$1" "$2"; }

echo "Tools"
for t in kubectl helm jq base64 minikube; do
  if command -v "$t" >/dev/null 2>&1; then pass "$t: $(command -v "$t")"
  else fail "$t not found" "Windows: winget install $(case $t in jq) echo jqlang.jq;; helm) echo Helm.Helm;; minikube) echo Kubernetes.minikube;; *) echo Kubernetes.kubectl;; esac)  |  Ubuntu: see the Ansible playbook"; fi
done

echo "Cluster"
ctx=$(kubectl config current-context 2>/dev/null)
if kubectl get --raw /readyz >/dev/null 2>&1; then pass "API reachable (context: $ctx)"
else fail "API unreachable (context: ${ctx:-none})" "minikube start -p ckad   (and: kubectl config use-context ckad)"; echo; exit 1; fi
v=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion')
pass "Server version: $v"
[ "$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready')" -ge 1 ] && pass "Node Ready" || fail "No Ready node" "kubectl get nodes"

echo "Add-ons used by the exercises"
if kubectl -n ingress-nginx get deploy ingress-nginx-controller >/dev/null 2>&1; then pass "Ingress NGINX (exercise 11)"
else fail "Ingress NGINX missing (exercise 11)" "minikube addons enable ingress -p ckad"; fi
if kubectl top nodes >/dev/null 2>&1; then pass "metrics-server answers (exercise 05)"
elif kubectl -n kube-system get deploy metrics-server >/dev/null 2>&1; then warn "metrics-server installed but not ready yet" "wait 1 min, then: kubectl top nodes"
else fail "metrics-server missing (exercise 05)" "minikube addons enable metrics-server -p ckad"; fi
if kubectl get pods -A -l k8s-app=calico-node --no-headers 2>/dev/null | grep -q Running \
   || kubectl get pods -A --no-headers 2>/dev/null | grep -Eq 'cilium|antrea|weave-net'; then
  pass "CNI enforces NetworkPolicies (exercise 10)"
else
  fail "CNI without NetworkPolicy support: exercise 10 cannot block traffic" \
       "dedicated cluster: minikube start -p ckad --cni=calico --addons=ingress,metrics-server"
fi
kubectl auth can-i '*' '*' >/dev/null 2>&1 && pass "Admin rights on the cluster" || fail "Not admin" "use the minikube context"

echo
echo "Result: $ok OK, $ko problem(s)."
[ "$ko" -eq 0 ] && echo "Ready! Next: bash bin/ckad list   then   bash bin/ckad start 01"
[ "$ko" -eq 0 ]
