#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-20
DF="$CKAD_ANSWERS_DIR/20-build/Dockerfile"
POD=$(jp pods -n "$NS" -l app=hello -o jsonpath='{.items[0].metadata.name}')

check "Dockerfile: FROM nginx:1.27-alpine, COPY index.html, LABEL maintainer=ckad" \
  'grep -Eqi "^FROM +nginx:1.27-alpine" "$DF" && grep -Eqi "^COPY .*index.html" "$DF" && grep -Eqi "^LABEL .*maintainer=\"?ckad" "$DF"'
check "Deployment hello: image ckad/hello:v1, imagePullPolicy Never" \
  '[ "$(jp deploy hello -n $NS -o jsonpath="{.spec.template.spec.containers[0].image}|{.spec.template.spec.containers[0].imagePullPolicy}")" = "ckad/hello:v1|Never" ]'
check "Pod hello runs (the image is present in the cluster)" \
  '[ "$(jp deploy hello -n $NS -o jsonpath={.status.availableReplicas})" = 1 ]'
check "The served image contains index.html" \
  '[ -n "$POD" ] && kx "$POD" -n $NS -- wget -qO- localhost | grep -q "Built for CKAD"'
check "Service hello: NodePort 80 → nodePort 30080" \
  '[ "$(jp svc hello -n $NS -o jsonpath="{.spec.type}/{.spec.ports[0].port}/{.spec.ports[0].nodePort}")" = NodePort/80/30080 ]'
check "Service hello answers" \
  'http_from $NS http://hello | grep -q "Built for CKAD"'

summary
