#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-07

check "ConfigMap app-config : APP_MODE=production, APP_PORT=8080" \
  '[ "$(jp cm app-config -n $NS -o jsonpath="{.data.APP_MODE}/{.data.APP_PORT}")" = production/8080 ]'
check "ConfigMap web-content contient index.html" \
  'jp cm web-content -n $NS -o jsonpath="{.data.index\.html}" | grep -q "CKAD lab"'
check "Secret db-creds : username=admin, password=S3cr3t!" \
  '[ "$(jp secret db-creds -n $NS -o jsonpath={.data.username} | base64 -d)" = admin ] && [ "$(jp secret db-creds -n $NS -o jsonpath={.data.password} | base64 -d)" = "S3cr3t!" ]'
check "Le pod app est Running" \
  '[ "$(jp pod app -n $NS -o jsonpath={.status.phase})" = Running ]'
check "app-config chargée via envFrom (APP_MODE et APP_PORT présents)" \
  '[ "$(jp pod app -n $NS -o jsonpath="{.spec.containers[0].envFrom[*].configMapRef.name}")" = app-config ] && [ "$(kx app -n $NS -- printenv APP_PORT)" = 8080 ]'
check "DB_PASSWORD provient du secret (secretKeyRef)" \
  '[ "$(jp pod app -n $NS -o jsonpath="{.spec.containers[0].env[?(@.name==\"DB_PASSWORD\")].valueFrom.secretKeyRef.name}")" = db-creds ] && [ "$(kx app -n $NS -- printenv DB_PASSWORD)" = "S3cr3t!" ]'
check "/usr/share/html/index.html est servi par la ConfigMap" \
  'kx app -n $NS -- cat /usr/share/html/index.html | grep -q "CKAD lab"'
check "Le secret est monté en lecture seule sur /etc/db" \
  '[ "$(kx app -n $NS -- cat /etc/db/username)" = admin ] && jp pod app -n $NS -o json | jq -e ".spec.containers[0].volumeMounts[] | select(.mountPath==\"/etc/db\") | .readOnly == true"'
check "~/ckad-answers/07-username.txt contient admin" \
  'grep -qx admin "$CKAD_ANSWERS_DIR/07-username.txt"'

summary
