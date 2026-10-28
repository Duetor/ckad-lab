# 06 — Dépannage d'une application cassée

**Domaine :** Application Observability and Maintenance
**Namespace :** `ckad-06`  ·  **Temps conseillé :** 9 min

## Contexte

Dans `ckad-06`, l'équipe a déployé un Deployment `backend`, son Service `backend` et un pod `worker`.
Rien ne fonctionne. Les noms des ressources ne doivent **pas** changer.

## Tâches

1. Le Service `backend` doit répondre en HTTP (port **80**) depuis un pod du namespace :
   `k run tmp --rm -it --image=busybox:1.36 -n ckad-06 -- wget -qO- http://backend`
   Trouve et corrige **tous** les problèmes (il y en a plusieurs).
2. Le pod `worker` est en CrashLoopBackOff.
   - Écris le **message d'erreur exact** affiché par le conteneur dans `~/ckad-answers/06-worker-error.txt`.
   - Corrige le pod pour qu'il passe en `Running` en définissant la variable `DB_HOST=postgres.ckad-06.svc`.
3. Écris dans `~/ckad-answers/06-events.txt` les événements de type `Warning` du namespace,
   triés par date (`.lastTimestamp`).

## Indices

- `k get pods,svc,endpointslices -n ckad-06` ; `k describe pod ...`
- Compare le `selector` du Service avec les labels réels des pods (`--show-labels`).
- Compare le `targetPort` du Service avec le port écouté par le conteneur.
- `k logs worker -n ckad-06 --previous`
- On ne peut pas modifier l'env d'un pod existant : `k get pod worker -o yaml > w.yaml`, édite, puis `k replace --force -f w.yaml`.
- `k get events --field-selector type=Warning --sort-by=.lastTimestamp`
