# 11 — Services et Ingress

**Domaine :** Services and Networking
**Namespace :** `ckad-11`  ·  **Temps conseillé :** 8 min

## Contexte

Deux Deployments tournent dans `ckad-11` : `app-a` et `app-b` (serveurs `http-echo` qui écoutent sur le port **5678**).

## Tâches

1. Expose `app-a` via un Service `ClusterIP` nommé `svc-a` sur le port **8080** (vers le port 5678 des pods).
2. Même chose pour `app-b` avec le Service `svc-b`.
3. Crée un Ingress `apps` (ingressClass `nginx`) pour l'hôte `ckad.local` :
   - `/a` (type `Prefix`) → `svc-a:8080`
   - `/b` (type `Prefix`) → `svc-b:8080`
4. Vérifie depuis ta machine : `curl http://ckad.local/a` doit répondre `Hello from A`.
   (Ansible a ajouté `ckad.local` dans `/etc/hosts`.)

## Indices

- `k expose deploy app-a --name=svc-a --port=8080 --target-port=5678 -n ckad-11`
- `k create ingress apps --class=nginx --rule="ckad.local/a*=svc-a:8080" --rule=... -n ckad-11`
  (le `*` final donne `pathType: Prefix`)
- `k describe ingress apps -n ckad-11` : vérifie les backends et leurs endpoints.
- Si `curl` échoue : `minikube ip -p ckad` doit correspondre à la ligne `ckad.local` de `/etc/hosts`.
