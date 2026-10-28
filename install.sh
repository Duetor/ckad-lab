#!/usr/bin/env bash
# Bootstrap : installe Ansible puis lance le playbook sur la machine locale.
#   git clone https://github.com/<toi>/ckad-lab.git && cd ckad-lab && ./install.sh
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo ">> Installation d'Ansible..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq ansible
fi

echo ">> Lancement du playbook (mot de passe sudo demandé)"
ansible-playbook site.yml -K "$@"
