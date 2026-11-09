# 15 — Adapter pattern

**Domain:** Application Design and Build
**Namespace:** `ckad-15`  ·  **Suggested time:** 7 min
*Variant of exercise 01: the second container transforms the first one's output.*

## Context

A legacy application writes its metrics in a custom format. The monitoring tool expects
lines prefixed with `METRIC`. You can't change the application: you add an **adapter**.

## Tasks

In `ckad-15`, create a pod `metrics`:

1. Container `app` (image `busybox:1.36`):
   `sh -c 'while true; do echo "cpu=$((RANDOM % 100)) mem=512" >> /data/raw.log; sleep 2; done'`
2. Container `adapter` (image `busybox:1.36`):
   `sh -c 'tail -n+1 -F /data/raw.log | awk "{print \"METRIC\", \$0; fflush()}"'`
3. An `emptyDir` volume named `data` mounted at `/data` in both containers —
   **read-only** in `adapter`.
4. The volume must be limited to **50Mi** (`sizeLimit`).
5. Each container has a memory limit of `32Mi`.

Check: `k logs metrics -c adapter -n ckad-15` prints lines like `METRIC cpu=...`.

## Hints

- The quotes in the `adapter` command are painful in YAML: use the
  `command: ["sh", "-c", "..."]` form or a `- |` block.
- `k explain pod.spec.volumes.emptyDir.sizeLimit`
- If `adapter` prints nothing: `k logs metrics -c app` and `k exec metrics -c adapter -- cat /data/raw.log`.
