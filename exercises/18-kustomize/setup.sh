#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
fresh_ns ckad-18
mkdir -p "$CKAD_ANSWERS_DIR/18-kustomize"
cp -r "$(dirname "$0")/files/base" "$CKAD_ANSWERS_DIR/18-kustomize/"
echo "Base copied to $CKAD_ANSWERS_DIR/18-kustomize/base"
