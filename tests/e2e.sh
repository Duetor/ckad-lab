#!/usr/bin/env bash
# Test de bout en bout : pour chaque exercice
#   1. setup  -> la correction doit ÉCHOUER (l'exercice n'est pas trivial)
#   2. solution -> la correction doit RÉUSSIR
set -uo pipefail
LAB="${CKAD_LAB_DIR:-$HOME/ckad-lab}"
ONLY="${1:-}"
failed=()

for d in "$LAB"/exercises/*/; do
  id=$(basename "$d" | cut -c1-2)
  [ -n "$ONLY" ] && [ "$ONLY" != "$id" ] && continue
  echo "::group::Exercice $id"
  ckad start "$id" >/dev/null || { failed+=("$id(setup)"); echo "::endgroup::"; continue; }
  if ckad check "$id" >/dev/null 2>&1; then failed+=("$id(check passe avant solution)"); fi
  bash "$d/solution.sh" || failed+=("$id(solution)")
  ckad check "$id" || failed+=("$id(check)")
  echo "::endgroup::"
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "ÉCHECS : ${failed[*]}"; exit 1
fi
echo "Tous les exercices passent."
