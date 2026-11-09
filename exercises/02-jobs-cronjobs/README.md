# 02 — Parallel Job and CronJob

**Domain:** Application Design and Build
**Namespace:** `ckad-02`  ·  **Suggested time:** 7 min

## Tasks

1. Create a **Job** `countdown` (image `busybox:1.36`) running
   `sh -c 'for i in 3 2 1; do echo $i; sleep 1; done; echo liftoff'` with:
   - `completions: 3`
   - `parallelism: 2`
   - `backoffLimit: 4`
   - pods must never be restarted in place (`restartPolicy: Never`)

   Wait for the Job to finish (3 successful completions).

2. Create a **CronJob** `cleanup` (image `busybox:1.36`, command `echo cleanup done`):
   - scheduled **every 15 minutes**
   - `concurrencyPolicy: Forbid`
   - keeps **2** successful and **1** failed job in its history
   - a started job must be killed if it runs longer than **30 seconds** (`activeDeadlineSeconds`)

3. Trigger the CronJob manually by creating a Job `cleanup-manual` from it.

## Hints

- `k create job countdown --image=busybox:1.36 $do -- sh -c '...'` then add completions/parallelism.
- `k create cronjob cleanup --image=busybox:1.36 --schedule='*/15 * * * *' $do -- echo cleanup done`
- `activeDeadlineSeconds` goes in `spec.jobTemplate.spec`.
- `k create job cleanup-manual --from=cronjob/cleanup -n ckad-02`
