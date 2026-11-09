# 11 — Services and Ingress

**Domain:** Services and Networking
**Namespace:** `ckad-11`  ·  **Suggested time:** 8 min

## Context

Two Deployments run in `ckad-11`: `app-a` and `app-b` (`http-echo` servers listening on port **5678**).

## Tasks

1. Expose `app-a` with a `ClusterIP` Service named `svc-a` on port **8080** (to the pods' port 5678).
2. Same for `app-b` with the Service `svc-b`.
3. Create an Ingress `apps` (ingressClass `nginx`) for host `ckad.local`:
   - `/a` (type `Prefix`) → `svc-a:8080`
   - `/b` (type `Prefix`) → `svc-b:8080`
4. Check: `curl http://ckad.local/a` must answer `Hello from A`.

## Hints

- `k expose deploy app-a --name=svc-a --port=8080 --target-port=5678 -n ckad-11`
- `k create ingress apps --class=nginx --rule="ckad.local/a*=svc-a:8080" --rule=... -n ckad-11`
  (the trailing `*` gives `pathType: Prefix`)
- `k describe ingress apps -n ckad-11`: check the backends and their endpoints.
- Linux (Ansible install): `ckad.local` is already in `/etc/hosts`.
- Windows + Docker driver: run `minikube tunnel -p ckad` in an admin terminal and add
  `127.0.0.1 ckad.local` to `C:\Windows\System32\drivers\etc\hosts`. `ckad check 11` works without it.
