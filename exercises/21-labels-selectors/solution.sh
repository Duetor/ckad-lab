#!/usr/bin/env bash
# Solution — exercise 21
set -euo pipefail
NS=ckad-21
ANS="${CKAD_ANSWERS_DIR:-$HOME/ckad-answers}"

kubectl get pods -n "$NS" --show-labels

# 1. AND selector (comma)
kubectl get pods -n "$NS" -l 'env=prod,tier=frontend' \
  -o custom-columns=NAME:.metadata.name --no-headers | sort > "$ANS/21-prod-frontend.txt"

# 6. (before changing anything) "env != prod" includes pods WITHOUT an env label
kubectl get pods -n "$NS" -l 'env!=prod' \
  -o custom-columns=NAME:.metadata.name --no-headers | sort > "$ANS/21-not-prod.txt"

# 2. Add a label
kubectl label pods -n "$NS" -l env=prod audit=true

# 3. Remove a label: name followed by "-"
kubectl label pods -n "$NS" -l temp temp-

# 4. Annotation
kubectl annotate pods -n "$NS" -l tier=backend owner=team-a

# 5. Delete by selector
kubectl delete pods -n "$NS" -l tier=cache --force --grace-period=0

kubectl get pods -n "$NS" --show-labels
