#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-17
pvc() { jp pvc data-pvc -n "$NS" -o jsonpath="{$1}"; }

check "PVC data-pvc Bound" '[ "$(pvc .status.phase)" = Bound ]'
check "PVC: 256Mi, ReadWriteOnce, StorageClass standard" \
  '[ "$(pvc .spec.resources.requests.storage)|$(pvc ".spec.accessModes[*]")|$(pvc .spec.storageClassName)" = "256Mi|ReadWriteOnce|standard" ]'
check "Pod writer was deleted" '! jp pod writer -n $NS'
check "Pod reader is Running and mounts data-pvc read-only at /data" \
  '[ "$(jp pod reader -n $NS -o jsonpath={.status.phase})" = Running ] && jp pod reader -n $NS -o json | jq -e "(.spec.volumes[] | select(.persistentVolumeClaim.claimName==\"data-pvc\") | .name) as \$v | .spec.containers[0].volumeMounts[] | select(.name==\$v and .mountPath==\"/data\" and .readOnly==true)"'
check "Data written by writer has persisted" \
  '[ "$(kx reader -n $NS -- cat /data/state.txt)" = persisted-writer ]'
check "~/ckad-answers/17-pv.txt contains the PV name" \
  '[ -n "$(pvc .spec.volumeName)" ] && grep -qx "$(pvc .spec.volumeName)" "$CKAD_ANSWERS_DIR/17-pv.txt"'

summary
