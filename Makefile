.PHONY: install lab lint test destroy

install:          ## Provision everything (prereqs, docker, kubectl, helm, minikube, lab)
	ansible-playbook site.yml -K

lab:              ## Re-copy only the exercises / the CLI
	ansible-playbook site.yml --tags lab -K

lint:             ## Lint Ansible + shell scripts
	ansible-playbook site.yml --syntax-check
	ansible-lint site.yml
	shellcheck -x install.sh bin/ckad lib/*.sh exercises/*/*.sh tests/*.sh

test:             ## Replay every exercise on the current cluster
	bash tests/e2e.sh

destroy:          ## Delete the minikube cluster
	minikube delete -p ckad
