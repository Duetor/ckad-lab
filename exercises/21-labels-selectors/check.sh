#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-21
names() { jp pods -n "$NS" "$@" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort | xargs; }

check "21-prod-frontend.txt: admin-ui, shop-ui" \
  '[ "$(tr -d "\r" < "$CKAD_ANSWERS_DIR/21-prod-frontend.txt" | sed "/^$/d" | xargs)" = "admin-ui shop-ui" ]'
check "audit=true on all env=prod pods (and only them)" \
  '[ "$(names -l audit=true)" = "admin-ui orders-api shop-ui" ]'
check "No pod has the temp label anymore" \
  '[ -z "$(names -l temp)" ] && [ -n "$(names)" ]'
check "Annotation owner=team-a on tier=backend pods" \
  '[ "$(jp pods -n $NS -l tier=backend -o jsonpath="{range .items[*]}{.metadata.annotations.owner} {end}" | xargs)" = "team-a team-a" ]'
check "tier=cache pods were deleted (and only them)" \
  '[ "$(names)" = "admin-ui orders-api preview-ui scratch shop-ui test-api" ]'
check "21-not-prod.txt: preview-ui, scratch, test-api" \
  '[ "$(tr -d "\r" < "$CKAD_ANSWERS_DIR/21-not-prod.txt" | sed "/^$/d" | xargs)" = "preview-ui scratch test-api" ]'

summary
