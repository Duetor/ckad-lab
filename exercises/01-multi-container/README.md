# 01 — Pod multi-conteneurs avec sidecar

**Domaine :** Application Design and Build
**Namespace :** `ckad-01`  ·  **Temps conseillé :** 6 min

## Contexte

Une équipe veut récupérer les logs d'une application qui écrit uniquement dans un fichier.

## Tâches

Dans le namespace `ckad-01`, crée un pod nommé `logger` :

1. Un conteneur `app` (image `busybox:1.36`) qui exécute :
   `sh -c 'while true; do date >> /var/log/app/app.log; sleep 2; done'`
2. Un conteneur `sidecar` (image `busybox:1.36`) qui exécute :
   `sh -c 'tail -n+1 -F /var/log/app/app.log'`
3. Les deux conteneurs partagent un volume `emptyDir` nommé `logs`, monté sur `/var/log/app`.

Vérifie ensuite que `kubectl logs logger -c sidecar -n ckad-01` affiche des dates.

> Un sidecar « natif » (initContainer avec `restartPolicy: Always`) est aussi accepté.

## Indices

- `k run logger --image=busybox:1.36 -n ckad-01 $do -- sh -c '...' > pod.yaml` donne un squelette.
- Duplique le bloc conteneur, renomme-les, puis ajoute `volumes:` au niveau du pod et `volumeMounts:` dans chaque conteneur.
- `k explain pod.spec.volumes.emptyDir`
