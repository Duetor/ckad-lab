# 07 — ConfigMaps et Secrets

**Domaine :** Application Environment, Configuration and Security
**Namespace :** `ckad-07`  ·  **Temps conseillé :** 8 min

## Tâches

1. Crée la ConfigMap `app-config` avec les clés `APP_MODE=production` et `APP_PORT=8080`.
2. Crée la ConfigMap `web-content` à partir du fichier
   `$CKAD_LAB_DIR/exercises/07-config-secrets/files/index.html` (clé `index.html`).
3. Crée le Secret générique `db-creds` avec `username=admin` et `password=S3cr3t!`.
4. Crée un pod `app` (image `busybox:1.36`, commande `sleep 3600`) qui :
   - charge **toutes** les clés de `app-config` comme variables d'environnement ;
   - expose la clé `password` de `db-creds` dans la variable `DB_PASSWORD` ;
   - monte `web-content` sur `/usr/share/html` ;
   - monte le Secret `db-creds` en **lecture seule** sur `/etc/db`.
5. Écris dans `~/ckad-answers/07-username.txt` la valeur **décodée** de `username`, lue depuis le Secret.

## Indices

- `k create cm app-config --from-literal=APP_MODE=production --from-literal=APP_PORT=8080`
- `k create cm web-content --from-file=<chemin>` ; `k create secret generic db-creds --from-literal=...`
- `envFrom: [{configMapRef: {name: app-config}}]` et `env[].valueFrom.secretKeyRef`
- Attention au `!` dans le shell : utilise des quotes simples.
- `k get secret db-creds -o jsonpath='{.data.username}' | base64 -d`
