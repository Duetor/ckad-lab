# 03 — Rolling update et rollback

**Domaine :** Application Deployment
**Namespace :** `ckad-03`  ·  **Temps conseillé :** 7 min

## Contexte

Le Deployment `web` vient d'être mis à jour par un collègue… et plus rien ne démarre.

## Tâches

1. Écris dans le fichier `~/ckad-answers/03-revision1.txt` l'**image** utilisée par la
   **révision 1** du Deployment `web` (une seule ligne, ex : `nginx:x.y`).
2. Reviens à la **dernière révision fonctionnelle** du Deployment (sans le recréer).
3. Configure la stratégie de mise à jour : `maxSurge: 1` et `maxUnavailable: 0`.
4. Passe le Deployment à **4 réplicas** et vérifie qu'ils sont tous disponibles.
5. Ajoute l'annotation `kubernetes.io/change-cause="rollback after broken release"` au Deployment.

## Indices

- `k rollout history deploy/web -n ckad-03` puis `--revision=1` pour le détail.
- `k rollout undo deploy/web -n ckad-03` (ou `--to-revision=N`).
- `k describe pod` ou `k get pods` pour comprendre pourquoi la dernière version ne démarre pas.
- `k patch deploy web -p '{"spec":{"strategy":{...}}}'` ou `k edit`.
- `k annotate deploy web kubernetes.io/change-cause="..."`
