#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
fresh_ns ckad-19
cp "$(dirname "$0")/files/legacy.yaml" "$CKAD_ANSWERS_DIR/19-legacy.yaml"
echo "File to migrate: $CKAD_ANSWERS_DIR/19-legacy.yaml"
