# 07 — ConfigMaps and Secrets

**Domain:** Application Environment, Configuration and Security
**Namespace:** `ckad-07`  ·  **Suggested time:** 8 min

## Tasks

1. Create the ConfigMap `app-config` with keys `APP_MODE=production` and `APP_PORT=8080`.
2. Create the ConfigMap `web-content` from the file
   `$CKAD_LAB_DIR/exercises/07-config-secrets/files/index.html` (key `index.html`).
3. Create the generic Secret `db-creds` with `username=admin` and `password=S3cr3t!`.
4. Create a pod `app` (image `busybox:1.36`, command `sleep 3600`) that:
   - loads **all** keys of `app-config` as environment variables;
   - exposes the `password` key of `db-creds` in the variable `DB_PASSWORD`;
   - mounts `web-content` at `/usr/share/html`;
   - mounts the Secret `db-creds` **read-only** at `/etc/db`.
5. Write the **decoded** value of `username`, read from the Secret, to `~/ckad-answers/07-username.txt`.

## Hints

- `k create cm app-config --from-literal=APP_MODE=production --from-literal=APP_PORT=8080`
- `k create cm web-content --from-file=<path>` ; `k create secret generic db-creds --from-literal=...`
- `envFrom: [{configMapRef: {name: app-config}}]` and `env[].valueFrom.secretKeyRef`
- Watch out for `!` in the shell: use single quotes.
- `k get secret db-creds -o jsonpath='{.data.username}' | base64 -d`
- If `$CKAD_LAB_DIR` is empty, use the path of your `ckad-lab` folder (e.g. `~/Documents/ckad-lab`).
