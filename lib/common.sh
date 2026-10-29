#!/usr/bin/env bash
# Helpers partagés par les scripts setup.sh / check.sh / solution.sh
# shellcheck disable=SC2034

CKAD_ANSWERS_DIR="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# Compatibilité Git Bash (Windows) :
#  - empêche MSYS de convertir /etc/db en C:/Program Files/Git/etc/db dans les arguments de kubectl.exe
#  - jq.exe écrit des fins de ligne CRLF : on retire les \r
export MSYS_NO_PATHCONV=1
if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  jq() { local out rc; out=$(command jq "$@"); rc=$?; [ -n "$out" ] && printf '%s\n' "${out//$'\r'/}"; return "$rc"; }
fi
mkdir -p "$CKAD_ANSWERS_DIR"

if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else G=; R=; Y=; B=; N=; fi

_PASS=0
_TOTAL=0

# check "description" 'expression bash évaluée'
check() {
  local desc="$1"; shift
  _TOTAL=$((_TOTAL + 1))
  if (eval "$*") >/dev/null 2>&1; then
    printf '  %s✔%s %s\n' "$G" "$N" "$desc"
    _PASS=$((_PASS + 1))
  else
    printf '  %s✘%s %s\n' "$R" "$N" "$desc"
  fi
}

# jp <args kubectl get...>  -> sortie silencieuse en cas d'erreur
jp() { kubectl get "$@" 2>/dev/null; }

# Exécute une commande dans un pod (silencieux)
kx() { kubectl exec "$@" 2>/dev/null; }

# Test HTTP depuis un pod jetable : http_from <ns> <url>
http_from() {
  kubectl run "probe-$RANDOM" -n "$1" --rm -i --restart=Never --quiet \
    --image=busybox:1.36 --command -- wget -qO- -T 5 "$2" 2>/dev/null
}

summary() {
  echo
  if [ "$_PASS" -eq "$_TOTAL" ]; then
    printf '%s%sBravo ! %d/%d critères validés.%s\n' "$B" "$G" "$_PASS" "$_TOTAL" "$N"
  else
    printf '%s%s%d/%d critères validés.%s  (ckad hint <id> pour un indice)\n' "$B" "$Y" "$_PASS" "$_TOTAL" "$N"
  fi
  echo "SCORE $_PASS/$_TOTAL"
  [ "$_PASS" -eq "$_TOTAL" ]
}

reset_ns() { kubectl delete namespace "$1" --ignore-not-found --wait=true >/dev/null; }
ensure_ns() { kubectl create namespace "$1" --dry-run=client -o yaml | kubectl apply -f - >/dev/null; }
fresh_ns() { reset_ns "$1"; ensure_ns "$1"; }
