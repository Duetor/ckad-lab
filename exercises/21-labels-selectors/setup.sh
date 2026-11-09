#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-21
fresh_ns "$NS"
mk() { kubectl run "$1" -n "$NS" --image=busybox:1.36 --labels="$2" --restart=Never -- sleep 3600 >/dev/null; }
mk shop-ui      env=prod,tier=frontend
mk admin-ui     env=prod,tier=frontend,temp=yes
mk orders-api   env=prod,tier=backend
mk preview-ui   env=staging,tier=frontend,temp=yes
mk test-api     env=dev,tier=backend
mk redis        env=prod,tier=cache
mk scratch      tier=tools,temp=yes
