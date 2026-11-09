#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
fresh_ns ckad-14
