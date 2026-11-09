# 20 — Build an image and deploy it

**Domain:** Application Design and Build
**Namespace:** `ckad-20`  ·  **Suggested time:** 8 min

## Context

The folder `~/ckad-answers/20-build/` contains an `index.html`. In the exam you use `docker` or `podman`;
here you build the image **directly inside minikube** (no registry).

## Tasks

1. Write a `Dockerfile` in `~/ckad-answers/20-build/`:
   - based on `nginx:1.27-alpine`;
   - copying `index.html` to `/usr/share/nginx/html/`;
   - adding the image label `maintainer=ckad`.
2. Build the image `ckad/hello:v1` inside the cluster:
   `minikube image build -t ckad/hello:v1 ~/ckad-answers/20-build -p ckad`
   (or `docker build` then `minikube image load ckad/hello:v1 -p ckad`).
3. Create a Deployment `hello` (1 replica) with this image and `imagePullPolicy: Never`.
4. Expose it with a Service `hello` of type **NodePort** on port 80, nodePort **30080**.

Check: `k run tmp --rm -it --image=busybox:1.36 -n ckad-20 -- wget -qO- http://hello` prints `Built for CKAD`.

## Hints

- `FROM`, `COPY`, `LABEL` are enough.
- `minikube image ls -p ckad | grep hello` checks the image is in the cluster.
- Without `imagePullPolicy: Never` (or `IfNotPresent`), Kubernetes would try to download the image and fail.
- `k expose deploy hello --type=NodePort --port=80`, then `k edit svc hello` to set the `nodePort`.
