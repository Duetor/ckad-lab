# 10 — NetworkPolicies

**Domaine :** Services and Networking
**Namespace :** `ckad-10`  ·  **Temps conseillé :** 9 min

## Contexte

Le namespace `ckad-10` contient 4 pods (regarde leurs labels !) :
`frontend`, `backend` (+ Service `backend`), `db` (+ Service `db`) et `intruder`.
Aujourd'hui tout le monde peut parler à tout le monde.

## Tâches

1. NetworkPolicy `default-deny` : bloque **tout le trafic entrant** vers **tous** les pods du namespace.
2. NetworkPolicy `allow-frontend-to-backend` : `backend` n'accepte que le trafic venant de
   `frontend`, en **TCP/80**.
3. NetworkPolicy `allow-backend-to-db` : `db` n'accepte que le trafic venant de `backend`, en **TCP/80**.
4. Ne modifie **pas** les labels des pods.

Résultat attendu :

| Source → Destination | Attendu |
|---|---|
| frontend → backend | ✅ |
| backend → db | ✅ |
| frontend → db | ❌ |
| intruder → backend | ❌ |

## Indices

- `k get pods -n ckad-10 --show-labels`
- Pas de `kubectl create netpol` : pars de la doc kubernetes.io (accessible à l'examen) ou `k explain networkpolicy.spec`.
- Une policy `podSelector: {}` + `policyTypes: [Ingress]` sans règle = deny all ingress.
- Test : `k exec frontend -n ckad-10 -- wget -qO- -T 3 http://db`
- Les policies s'additionnent : l'ordre n'a pas d'importance.
