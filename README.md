# ckad-lab

Lab d'entraînement **CKAD** reproductible : un playbook **Ansible** installe Docker, kubectl, Helm et
**minikube** (CNI Calico + Ingress NGINX + metrics-server), configure le shell comme à l'examen,
puis installe **12 exercices** auto-corrigés couvrant les 5 domaines du programme.

## Démarrage rapide

Sur une machine **Ubuntu/Debian** (VM, WSL2 ou bare metal — 2 vCPU et ~6 Go de RAM minimum) :

```bash
git clone https://github.com/<ton-compte>/ckad-lab.git
cd ckad-lab
./install.sh            # installe Ansible si besoin, puis lance le playbook (demande ton mot de passe sudo)
source ~/.bashrc
ckad list
```

Ou directement : `ansible-playbook site.yml -K`

> **WSL2** : active systemd (`[boot]\nsystemd=true` dans `/etc/wsl.conf`, puis `wsl --shutdown`) avant de lancer le playbook.
> Le playbook est idempotent : tu peux le relancer sans risque, il ne recrée pas le cluster s'il tourne déjà.

## Utiliser un minikube existant (sans le playbook)

La CLI et les exercices marchent sur n'importe quel cluster accessible par `kubectl`, y compris
depuis **Git Bash sous Windows** (il faut `kubectl`, `helm` et `jq` dans le PATH) :

```bash
minikube start -p ckad --cni=calico --addons=ingress,metrics-server   # cluster dédié recommandé
bash tests/preflight.sh        # vérifie outils, add-ons et CNI
bash bin/ckad list
bash tests/e2e.sh 01           # rejoue un exercice : setup -> solution -> correction
bash tests/e2e.sh              # rejoue les 12
```

## Utilisation

```text
ckad list                 Liste les exercices et ta progression
ckad start 03             Prépare l'exercice (namespace propre) et affiche l'énoncé
ckad hint 03              Indices
ckad check 03             Correction automatique
ckad solution 03          Solution commentée
ckad reset 03|all         Remet à zéro
ckad exam 90              Mode examen : tous les exercices + chrono
ckad status               Temps restant
ckad check all            Score global (l'examen se réussit à 66 %)
```

Les fichiers de réponse attendus par certains exercices vont dans `~/ckad-answers/`.

Le shell est configuré comme à l'examen : `alias k=kubectl` + complétion, `$do` (`--dry-run=client -o yaml`),
`$now` (`--force --grace-period 0`), vim en indentation 2 espaces.

## Exercices

| # | Sujet | Domaine CKAD |
|---|---|---|
| 01 | Pod multi-conteneurs / sidecar | Application Design and Build |
| 02 | Job parallèle et CronJob | Application Design and Build |
| 03 | Rolling update et rollback | Application Deployment |
| 04 | Déploiement canary | Application Deployment |
| 05 | Probes et ressources | Observability and Maintenance |
| 06 | Dépannage d'une application cassée | Observability and Maintenance |
| 07 | ConfigMaps et Secrets | Environment, Configuration and Security |
| 08 | ServiceAccount, RBAC, SecurityContext | Environment, Configuration and Security |
| 09 | ResourceQuota et LimitRange | Environment, Configuration and Security |
| 10 | NetworkPolicies | Services and Networking |
| 11 | Services et Ingress | Services and Networking |
| 12 | Helm : install, upgrade, rollback | Application Deployment |

## Structure

```text
.
├── site.yml                  # playbook principal
├── group_vars/all.yml        # versions (k8s, helm), ressources minikube, chemins
├── inventory/hosts.ini       # localhost par défaut (ou une VM distante)
├── roles/
│   ├── prereqs/              # paquets de base
│   ├── docker/               # docker.io + groupe docker
│   ├── kubectl/              # binaire vérifié par sha256
│   ├── helm/
│   ├── minikube/             # install + start idempotent + /etc/hosts
│   ├── shell/                # alias, complétion, vimrc
│   └── lab/                  # copie exercices + CLI ckad
├── bin/ckad                  # CLI
├── lib/common.sh             # helpers de correction
├── exercises/NN-xxx/         # README.md, setup.sh, check.sh, solution.sh
├── tests/e2e.sh              # setup -> check KO -> solution -> check OK
└── .github/workflows/ci.yml  # lint + test e2e complet sur runner GitHub
```

## Personnaliser

- **Version Kubernetes** : `kubernetes_version` dans `group_vars/all.yml` — aligne-la sur celle annoncée
  par la Linux Foundation pour l'examen.
- **Ressources** : `minikube_cpus`, `minikube_memory_mb`.
- **Machine distante** : modifie `inventory/hosts.ini` (`ansible_host`, `ansible_user`).
- **Rejouer une partie** : `ansible-playbook site.yml -K --tags lab` (ex : après avoir ajouté un exercice).

## Ajouter un exercice

Crée `exercises/13-mon-sujet/` avec :

- `README.md` — 1re ligne `# 13 — Titre`, une ligne `**Domaine :** ...`, puis une section `## Indices` à la fin ;
- `setup.sh` — crée le namespace `ckad-13` (`fresh_ns ckad-13`) et l'état initial ;
- `check.sh` — une suite de `check "description" 'expression bash'` terminée par `summary` ;
- `solution.sh` — doit faire passer `check.sh` (vérifié par la CI).

## Nettoyage

```bash
minikube delete -p ckad
```
