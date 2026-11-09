#!/usr/bin/env bash
# shellcheck source=../../lib/common.sh
source "$(dirname "$0")/../../lib/common.sh"
NS=ckad-02

check "Job countdown: completions=3, parallelism=2, backoffLimit=4" \
  '[ "$(jp job countdown -n $NS -o jsonpath="{.spec.completions}/{.spec.parallelism}/{.spec.backoffLimit}")" = "3/2/4" ]'
check "Job countdown: restartPolicy Never" \
  '[ "$(jp job countdown -n $NS -o jsonpath={.spec.template.spec.restartPolicy})" = Never ]'
check "Job countdown: 3 succeeded pods" \
  '[ "$(jp job countdown -n $NS -o jsonpath={.status.succeeded})" = 3 ]'
check "Job logs contain liftoff" \
  'kubectl logs job/countdown -n $NS 2>/dev/null | grep -q liftoff'
check "CronJob cleanup scheduled every 15 minutes" \
  's=$(jp cronjob cleanup -n $NS -o jsonpath={.spec.schedule}); [ "$s" = "*/15 * * * *" ] || [ "$s" = "0,15,30,45 * * * *" ]'
check "CronJob cleanup: concurrencyPolicy Forbid" \
  '[ "$(jp cronjob cleanup -n $NS -o jsonpath={.spec.concurrencyPolicy})" = Forbid ]'
check "CronJob cleanup: history 2 successful / 1 failed" \
  '[ "$(jp cronjob cleanup -n $NS -o jsonpath="{.spec.successfulJobsHistoryLimit}/{.spec.failedJobsHistoryLimit}")" = "2/1" ]'
check "CronJob cleanup: activeDeadlineSeconds=30" \
  '[ "$(jp cronjob cleanup -n $NS -o jsonpath={.spec.jobTemplate.spec.activeDeadlineSeconds})" = 30 ]'
check "Job cleanup-manual created from the CronJob" \
  '[ "$(jp job cleanup-manual -n $NS -o jsonpath="{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}")" = "CronJob/cleanup" ] || [ "$(jp job cleanup-manual -n $NS -o jsonpath="{.metadata.annotations.cronjob\.kubernetes\.io/instantiate}")" = manual ]'

summary
