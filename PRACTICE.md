# How to practice

This guide explains how to **run** an exercise, how to get it **graded**, and how to use the **hints**
and **solutions** without spoiling your training.

## 0. Before each session

1. **Start the cluster** (it stops when you reboot your PC):
   ```bash
   minikube start -p ckad
   kubectl config use-context ckad
   ```
2. **Open a terminal in the lab folder.** On Windows use **Git Bash**, not PowerShell:
   ```bash
   cd ~/Documents/ckad-lab        # or wherever you cloned the repo
   ```
3. **First time only — check your environment:**
   ```bash
   bash tests/preflight.sh        # every line should be ✔
   ```
4. **First time only — add the exam shortcuts** to `~/.bashrc` (already done by the Ansible install):
   ```bash
   cat >> ~/.bashrc <<'BASHRC'
   alias ckad="bash ~/Documents/ckad-lab/bin/ckad"
   alias k=kubectl
   export do="--dry-run=client -o yaml"
   export now="--force --grace-period 0"
   BASHRC
   source ~/.bashrc
   ```
   Change the path in the `alias ckad=` line if your lab lives somewhere else.

## 1. Pick an exercise

```bash
ckad list
```

```text
ID   Exercise                                     Domain                                   Status
01   Multi-container pod with a sidecar           Design and Build                         ✔ passed
02   Parallel Job and CronJob                     Design and Build                         … in progress
03   Rolling update and rollback                  Deployment                               -
...
```

Suggested order: 01 → 13 → 14 → 15 → 16 (multi-container family), then the others in any order.

## 2. Run (start) it

```bash
ckad start 01
```

This command:

- **deletes and recreates** the namespace `ckad-01` (you always start from a clean state);
- creates what the exercise needs (broken apps, files to fix, pods to inspect…);
- prints the **task**: context, numbered tasks, suggested time.

Print the task again at any time with `ckad show 01`.

## 3. Solve it — like in the real exam

Use only `kubectl` (and `helm`, `minikube image` when asked) plus the official docs at kubernetes.io,
which are allowed during the exam. Typical workflow:

```bash
# generate a skeleton instead of writing YAML from scratch
k run logger --image=busybox:1.36 -n ckad-01 $do -- sh -c 'sleep 1' > logger.yaml

# edit it (notepad, code, vim...)
code logger.yaml

# apply and inspect
k apply -f logger.yaml
k get pods -n ckad-01
k describe pod logger -n ckad-01
k logs logger -c sidecar -n ckad-01

# look up a field
k explain pod.spec.volumes.emptyDir
```

Things to watch out for:

- **Always use the namespace** given by the task (`-n ckad-01`). Forgetting it is the #1 exam mistake.
- **Answer files**: some tasks ask you to write a result to a file, e.g.
  `~/ckad-answers/03-revision1.txt`. On Windows that folder is `C:\Users\<you>\ckad-answers`.
- **Respect the names** (pods, containers, volumes, labels) exactly: the grader looks for them.
- Keep an eye on the **suggested time**: the real exam is about speed.

## 4. Get it graded (correct it)

```bash
ckad check 01
```

```text
== 01 — Multi-container pod with a sidecar
  ✔ Pod logger exists and is Running
  ✔ It has the containers app and sidecar
  ✘ Volume logs is an emptyDir
  ✘ logs is mounted at /var/log/app in both containers
  ✔ The sidecar prints log lines

3/5 criteria passed.  (fix the ✘ lines and run the check again — stuck? ckad hint 01)
```

- Every line is **one criterion** from the task. ✔ = done, ✘ = missing or wrong.
- The grader **only reads** the cluster and your answer files: it never changes anything.
  Run it as many times as you want.
- Fix the ✘ lines, then run `ckad check 01` again until everything is ✔.
- Once all criteria pass, `ckad list` shows the exercise as **✔ passed**.

## 5. Stuck? Hints first, then the solution

```bash
ckad hint 01        # hints: the right commands / fields to look at, without the full answer
```

Try again with the hints. If you're still stuck:

```bash
ckad solution 01    # the full commented solution (asks for confirmation)
```

The solution is a runnable script with comments explaining **why** each step is needed. Read it,
then **redo the exercise from scratch without looking**:

```bash
ckad start 01       # resets everything
```

An exercise is only really learned when you can pass it alone, within the suggested time.

## 6. Start over

```bash
ckad reset 01       # delete the namespace and your answer files for exercise 01
ckad reset all      # same for every exercise
```

`ckad start 01` also resets automatically.

## 7. Mock exam

When most exercises pass on their own:

```bash
ckad exam 120       # sets up every exercise at once + starts a 120-minute timer
ckad show 07        # read any task
ckad status         # time left
ckad check all      # final score, per exercise and global
```

The real CKAD pass mark is **66%**. Aim for 80%+ here before booking the exam.

## Troubleshooting

| Problem | Fix |
|---|---|
| `Error: cluster unreachable` | `minikube start -p ckad`, then `kubectl config use-context ckad` |
| `ckad: command not found` | Use `bash bin/ckad ...` from the lab folder, or add the alias (step 0.4) |
| Pods stuck in `ContainerCreating` / `ErrImagePull` | First run downloads images: wait 1–2 min, check `k describe pod` |
| Exercise 10 always fails on "blocked" lines | Your cluster has no Calico: recreate it with `--cni=calico` |
| Exercise 05 fails on `kubectl top` | metrics-server needs ~1 min after start: `minikube addons enable metrics-server -p ckad` |
| `curl http://ckad.local` doesn't work (Windows) | Normal with the Docker driver; `ckad check 11` still works. See exercise 11 hints |
| A check looks wrong | Run `bash tests/e2e.sh <id>`: it applies the official solution and grades it |
