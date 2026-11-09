#!/usr/bin/env bash
# Bootstrap: installs Ansible, then runs the playbook on the local machine (Ubuntu/Debian).
#   git clone https://github.com/<you>/ckad-lab.git && cd ckad-lab && ./install.sh
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo ">> Installing Ansible..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq ansible
fi

echo ">> Running the playbook (you will be asked for your sudo password)"
ansible-playbook site.yml -K "$@"
