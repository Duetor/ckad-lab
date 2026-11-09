# ckad-lab

A reproducible **CKAD** practice lab: an **Ansible** playbook installs Docker, kubectl, Helm and
**minikube** (Calico CNI + Ingress NGINX + metrics-server), sets up the shell like in the exam,
then installs **22 auto-graded exercises** covering the 5 domains of the curriculum.

➡️ **New here? Read [PRACTICE.md](PRACTICE.md)**: how to run an exercise, get it graded and use the hints.

## Quick start

### Option A — Ubuntu/Debian (VM, WSL2 or bare metal): full install with Ansible

2 vCPU and ~6 GB of RAM minimum.

```bash
git clone https://github.com/<your-account>/ckad-lab.git
cd ckad-lab
./install.sh            # installs Ansible if needed, then runs the playbook (asks for your sudo password)
source ~/.bashrc
ckad list
```

Or directly: `ansible-playbook site.yml -K`

> **WSL2**: enable systemd (`[boot]` / `systemd=true` in `/etc/wsl.conf`, then `wsl --shutdown`) before running the playbook.
> The playbook is idempotent: you can run it again safely, it won't recreate a running cluster.

### Option B — an existing minikube (Windows + Docker Desktop, macOS…): no Ansible

The CLI and the exercises work on any cluster reachable with `kubectl`, including from
**Git Bash on Windows** (you need `kubectl`, `helm`, `jq` and `minikube` on your PATH):

```bash
minikube start -p ckad --driver=docker --cni=calico --addons=ingress,metrics-server --memory=4096
bash tests/preflight.sh        # checks tools, add-ons and CNI
bash bin/ckad list
```

Windows: `winget install jqlang.jq Helm.Helm` for the missing tools.

## Commands

```text
ckad list                 List the exercises and your progress
ckad start 03             Set up the exercise (fresh namespace) and print the task
ckad hint 03              Hints
ckad check 03             Automatic grading
ckad solution 03          Commented solution
ckad reset 03|all         Start over
ckad exam 120             Exam mode: every exercise + a timer
ckad status               Time left
ckad check all            Global score (the exam pass mark is 66%)
```

Answer files expected by some exercises go to `~/ckad-answers/`.

With the Ansible install, the shell is configured like in the exam: `alias k=kubectl` + completion,
`$do` (`--dry-run=client -o yaml`), `$now` (`--force --grace-period 0`), vim with 2-space indentation.

## Exercises

| # | Topic | CKAD domain |
|---|---|---|
| 01 | Multi-container pod / sidecar | Application Design and Build |
| 02 | Parallel Job and CronJob | Application Design and Build |
| 03 | Rolling update and rollback | Application Deployment |
| 04 | Canary deployment | Application Deployment |
| 05 | Probes and resources | Observability and Maintenance |
| 06 | Troubleshooting a broken application | Observability and Maintenance |
| 07 | ConfigMaps and Secrets | Environment, Configuration and Security |
| 08 | ServiceAccount, RBAC, SecurityContext | Environment, Configuration and Security |
| 09 | ResourceQuota and LimitRange | Environment, Configuration and Security |
| 10 | NetworkPolicies | Services and Networking |
| 11 | Services and Ingress | Services and Networking |
| 12 | Helm: install, upgrade, rollback | Application Deployment |
| 13 | Init container (variant of 01) | Application Design and Build |
| 14 | Native sidecar in a Deployment (variant of 01) | Application Design and Build |
| 15 | Adapter pattern (variant of 01) | Application Design and Build |
| 16 | Troubleshooting a multi-container pod (variant of 01) | Observability and Maintenance |
| 17 | PVC and data persistence | Environment, Configuration and Security |
| 18 | Kustomize: production overlay | Application Deployment |
| 19 | Migrating deprecated APIs | Application Deployment |
| 20 | Build an image and deploy it | Application Design and Build |
| 21 | Labels, selectors and annotations | Application Deployment |
| 22 | Debugging without a shell (kubectl debug) | Observability and Maintenance |

## Layout

```text
.
├── PRACTICE.md               # how to practice: run / check / hints
├── site.yml                  # main playbook
├── group_vars/all.yml        # versions (k8s, helm), minikube resources, paths
├── inventory/hosts.ini       # localhost by default (or a remote VM)
├── roles/
│   ├── prereqs/              # base packages
│   ├── docker/               # docker.io + docker group
│   ├── kubectl/              # binary verified with sha256
│   ├── helm/
│   ├── minikube/             # idempotent install + start + /etc/hosts
│   ├── shell/                # aliases, completion, vimrc
│   └── lab/                  # copies the exercises + the ckad CLI
├── bin/ckad                  # CLI
├── lib/common.sh             # grading helpers
├── exercises/NN-xxx/         # README.md, setup.sh, check.sh, solution.sh
├── tests/preflight.sh        # checks your environment
├── tests/e2e.sh              # setup -> check fails -> solution -> check passes
└── .github/workflows/ci.yml  # lint + full e2e test on a GitHub runner
```

## Testing the lab itself

```bash
bash tests/e2e.sh 13      # replay one exercise: setup -> solution -> grading
bash tests/e2e.sh         # replay all 22 (~20-30 min, image downloads)
bash bin/ckad reset all   # then clean up before practicing for real
```

The GitHub Actions CI runs the lint and this full test on every push.

## Customizing

- **Kubernetes version**: `kubernetes_version` in `group_vars/all.yml` — align it with the version
  announced by the Linux Foundation for the exam.
- **Resources**: `minikube_cpus`, `minikube_memory_mb`.
- **Remote machine**: edit `inventory/hosts.ini` (`ansible_host`, `ansible_user`).
- **Re-run one part**: `ansible-playbook site.yml -K --tags lab` (e.g. after adding an exercise).

## Adding an exercise

Create `exercises/23-my-topic/` with:

- `README.md` — first line `# 23 — Title`, a `**Domain:** ...` line, then a `## Hints` section at the end;
- `setup.sh` — creates the namespace `ckad-23` (`fresh_ns ckad-23`) and the initial state;
- `check.sh` — a list of `check "description" 'bash expression'` ending with `summary`;
- `solution.sh` — must make `check.sh` pass (verified by the CI).

## Cleanup

```bash
minikube delete -p ckad
```
