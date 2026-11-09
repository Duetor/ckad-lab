# 10 — NetworkPolicies

**Domain:** Services and Networking
**Namespace:** `ckad-10`  ·  **Suggested time:** 9 min

## Context

Namespace `ckad-10` contains 4 pods (look at their labels!):
`frontend`, `backend` (+ Service `backend`), `db` (+ Service `db`) and `intruder`.
Right now everyone can talk to everyone.

## Tasks

1. NetworkPolicy `default-deny`: blocks **all incoming traffic** to **all** pods in the namespace.
2. NetworkPolicy `allow-frontend-to-backend`: `backend` only accepts traffic from
   `frontend`, on **TCP/80**.
3. NetworkPolicy `allow-backend-to-db`: `db` only accepts traffic from `backend`, on **TCP/80**.
4. Do **not** change the pod labels.

Expected result:

| Source → Destination | Expected |
|---|---|
| frontend → backend | ✅ |
| backend → db | ✅ |
| frontend → db | ❌ |
| intruder → backend | ❌ |

## Hints

- `k get pods -n ckad-10 --show-labels`
- There's no `kubectl create netpol`: start from the kubernetes.io docs (allowed during the exam) or `k explain networkpolicy.spec`.
- A policy with `podSelector: {}` + `policyTypes: [Ingress]` and no rules = deny all ingress.
- Test: `k exec frontend -n ckad-10 -- wget -qO- -T 3 http://db`
- Policies add up: their order doesn't matter.
- This exercise needs a CNI that enforces NetworkPolicies (Calico): `minikube start -p ckad --cni=calico`.
