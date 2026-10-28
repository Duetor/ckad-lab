# 02 — Job parallèle et CronJob

**Domaine :** Application Design and Build
**Namespace :** `ckad-02`  ·  **Temps conseillé :** 7 min

## Tâches

1. Crée un **Job** `countdown` (image `busybox:1.36`) qui exécute
   `sh -c 'for i in 3 2 1; do echo $i; sleep 1; done; echo liftoff'` avec :
   - `completions: 3`
   - `parallelism: 2`
   - `backoffLimit: 4`
   - les pods ne doivent jamais redémarrer en place (`restartPolicy: Never`)

   Attends que le Job soit terminé (3 complétions réussies).

2. Crée un **CronJob** `cleanup` (image `busybox:1.36`, commande `echo cleanup done`) :
   - planifié **toutes les 15 minutes**
   - `concurrencyPolicy: Forbid`
   - conserve **2** jobs réussis et **1** job échoué dans l'historique
   - un job démarré doit être tué s'il dure plus de **30 secondes** (`activeDeadlineSeconds`)

3. Déclenche manuellement le CronJob en créant un Job `cleanup-manual` à partir de celui-ci.

## Indices

- `k create job countdown --image=busybox:1.36 $do -- sh -c '...'` puis ajoute completions/parallelism.
- `k create cronjob cleanup --image=busybox:1.36 --schedule='*/15 * * * *' $do -- echo cleanup done`
- `activeDeadlineSeconds` se place dans `spec.jobTemplate.spec`.
- `k create job cleanup-manual --from=cronjob/cleanup -n ckad-02`
