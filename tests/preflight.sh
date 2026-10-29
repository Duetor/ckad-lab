#!/usr/bin/env bash
# Vérifie que le poste et le cluster courant (kubectl context) sont prêts pour les exercices.
# Fonctionne sous Linux, WSL et Git Bash (Windows).
export MSYS_NO_PATHCONV=1
ok=0; ko=0
if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; N=$'\e[0m'; else G=; R=; Y=; N=; fi
pass() { printf '  %s✔%s %s\n' "$G" "$N" "$1"; ok=$((ok+1)); }
fail() { printf '  %s✘%s %s\n     → %s\n' "$R" "$N" "$1" "$2"; ko=$((ko+1)); }
warn() { printf '  %s!%s %s\n     → %s\n' "$Y" "$N" "$1" "$2"; }

echo "Outils"
for t in kubectl helm jq base64; do
  if command -v "$t" >/dev/null 2>&1; then pass "$t : $(command -v "$t")"
  else fail "$t introuvable" "Windows : winget install $( [ $t = jq ] && echo jqlang.jq || echo Helm.Helm )  |  Ubuntu : sudo apt install $t"; fi
done

echo "Cluster"
ctx=$(kubectl config current-context 2>/dev/null)
if kubectl get --raw /readyz >/dev/null 2>&1; then pass "API joignable (contexte : $ctx)"
else fail "API injoignable (contexte : ${ctx:-aucun})" "minikube start  (ou minikube start -p ckad ...)"; echo; exit 1; fi
v=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion')
pass "Version serveur : $v"
[ "$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready')" -ge 1 ] && pass "Nœud Ready" || fail "Aucun nœud Ready" "kubectl get nodes"

echo "Add-ons utilisés par les exercices"
if kubectl -n ingress-nginx get deploy ingress-nginx-controller >/dev/null 2>&1; then pass "Ingress NGINX (exercice 11)"
else fail "Ingress NGINX absent (exercice 11)" "minikube addons enable ingress"; fi
if kubectl top nodes >/dev/null 2>&1; then pass "metrics-server répond (exercice 05)"
elif kubectl -n kube-system get deploy metrics-server >/dev/null 2>&1; then warn "metrics-server installé mais pas encore prêt" "attends 1 min puis : kubectl top nodes"
else fail "metrics-server absent (exercice 05)" "minikube addons enable metrics-server"; fi
if kubectl get pods -A -l k8s-app=calico-node --no-headers 2>/dev/null | grep -q Running \
   || kubectl get pods -A --no-headers 2>/dev/null | grep -Eq 'cilium|antrea|weave-net'; then
  pass "CNI compatible NetworkPolicy (exercice 10)"
else
  fail "CNI sans support NetworkPolicy : l'exercice 10 ne pourra pas bloquer le trafic" \
       "cluster dédié : minikube start -p ckad --cni=calico --addons=ingress,metrics-server"
fi
kubectl auth can-i '*' '*' >/dev/null 2>&1 && pass "Droits admin sur le cluster" || fail "Pas admin" "utilise le contexte minikube"

echo
echo "Résultat : $ok OK, $ko problème(s)."
[ "$ko" -eq 0 ]
