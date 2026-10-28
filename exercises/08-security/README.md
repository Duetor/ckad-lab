# 08 — ServiceAccount, RBAC et SecurityContext

**Domaine :** Application Environment, Configuration and Security
**Namespace :** `ckad-08`  ·  **Temps conseillé :** 9 min

## Tâches

1. Crée le ServiceAccount `monitor`.
2. Crée le Role `pod-reader` autorisant `get`, `list`, `watch` sur les `pods` (et rien d'autre).
3. Lie ce Role au ServiceAccount `monitor` avec le RoleBinding `monitor-binding`.
4. Crée un pod `secure` (image `busybox:1.36`, commande `sleep 3600`) qui :
   - utilise le ServiceAccount `monitor` ;
   - s'exécute avec l'UID `1000` et le GID `3000` (au niveau du **pod**) ;
   - empêche l'escalade de privilèges, a un système de fichiers racine en **lecture seule**,
     et supprime **toutes** les capabilities Linux (au niveau du **conteneur**).
5. Vérifie avec `kubectl auth can-i` que `monitor` peut lister les pods mais **pas** les supprimer.

## Indices

- `k create sa monitor` ; `k create role pod-reader --verb=get,list,watch --resource=pods`
- `k create rolebinding monitor-binding --role=pod-reader --serviceaccount=ckad-08:monitor`
- `k auth can-i list pods --as=system:serviceaccount:ckad-08:monitor -n ckad-08`
- `k explain pod.spec.securityContext` vs `k explain pod.spec.containers.securityContext`
