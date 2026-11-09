#!/usr/bin/env bash
# End-to-end test, for each exercise:
#   1. setup    -> the check must FAIL (the exercise is not trivially passing)
#   2. solution -> the check must PASS
# Usage: bash tests/e2e.sh [id]      (e.g. bash tests/e2e.sh 13)
set -uo pipefail
# Default: the repo itself (works without running the Ansible playbook)
LAB="${CKAD_LAB_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
export CKAD_LAB_DIR="$LAB" MSYS_NO_PATHCONV=1
ckad() { bash "$LAB/bin/ckad" "$@"; }
ONLY="${1:-}"
[ -n "$ONLY" ] && ONLY=$(printf '%02d' "$((10#$ONLY))")
failed=()

for d in "$LAB"/exercises/*/; do
  id=$(basename "$d" | cut -c1-2)
  [ -n "$ONLY" ] && [ "$ONLY" != "$id" ] && continue
  echo "::group::Exercise $id"
  ckad start "$id" >/dev/null || { failed+=("$id(setup)"); echo "::endgroup::"; continue; }
  if ckad check "$id" >/dev/null 2>&1; then failed+=("$id(check passes before the solution)"); fi
  bash "$d/solution.sh" || failed+=("$id(solution)")
  ckad check "$id" || failed+=("$id(check)")
  echo "::endgroup::"
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILURES: ${failed[*]}"; exit 1
fi
echo "All exercises pass."
echo "Tip: run 'bash bin/ckad reset all' before practicing, to remove the solutions applied by this test."
