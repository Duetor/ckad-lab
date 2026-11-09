#!/usr/bin/env bash
# Helpers shared by the setup.sh / check.sh / solution.sh scripts
# shellcheck disable=SC2034

CKAD_ANSWERS_DIR="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

# Git Bash (Windows) compatibility:
#  - stops MSYS from rewriting /etc/db into C:/Program Files/Git/etc/db in kubectl.exe arguments
#  - jq.exe writes CRLF line endings: strip the \r
export MSYS_NO_PATHCONV=1
if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  jq() { local out rc; out=$(command jq "$@"); rc=$?; [ -n "$out" ] && printf '%s\n' "${out//$'\r'/}"; return "$rc"; }
fi
mkdir -p "$CKAD_ANSWERS_DIR"

if [ -t 1 ]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else G=; R=; Y=; B=; N=; fi

_PASS=0
_TOTAL=0

# check "description" 'bash expression to evaluate'
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

# jp <kubectl get args...>  -> silent on error
jp() { kubectl get "$@" 2>/dev/null; }

# Run a command in a pod (silent)
kx() { kubectl exec "$@" 2>/dev/null; }

# HTTP test from a throwaway pod: http_from <ns> <url>
http_from() {
  kubectl run "probe-$RANDOM" -n "$1" --rm -i --restart=Never --quiet \
    --image=busybox:1.36 --command -- wget -qO- -T 5 "$2" 2>/dev/null
}

summary() {
  echo
  if [ "$_PASS" -eq "$_TOTAL" ]; then
    printf '%s%sWell done! %d/%d criteria passed.%s\n' "$B" "$G" "$_PASS" "$_TOTAL" "$N"
  else
    printf '%s%s%d/%d criteria passed.%s  (fix the ✘ lines and run the check again — stuck? ckad hint <id>)\n' "$B" "$Y" "$_PASS" "$_TOTAL" "$N"
  fi
  echo "SCORE $_PASS/$_TOTAL"
  [ "$_PASS" -eq "$_TOTAL" ]
}

reset_ns() { kubectl delete namespace "$1" --ignore-not-found --wait=true >/dev/null; }
ensure_ns() { kubectl create namespace "$1" --dry-run=client -o yaml | kubectl apply -f - >/dev/null; }
fresh_ns() { reset_ns "$1"; ensure_ns "$1"; }
