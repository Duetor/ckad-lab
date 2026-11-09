#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
fresh_ns ckad-20
mkdir -p "$CKAD_ANSWERS_DIR/20-build"
cp "$(dirname "$0")/files/index.html" "$CKAD_ANSWERS_DIR/20-build/"
echo "Build folder: $CKAD_ANSWERS_DIR/20-build"
