.PHONY: install lab lint destroy

install:          ## Provisionne tout (prérequis, docker, kubectl, helm, minikube, lab)
	ansible-playbook site.yml -K

lab:              ## Recopie seulement les exercices / la CLI
	ansible-playbook site.yml --tags lab -K

lint:             ## Lint Ansible + scripts shell
	ansible-playbook site.yml --syntax-check
	ansible-lint site.yml
	shellcheck -x bin/ckad lib/*.sh exercises/*/*.sh

destroy:          ## Supprime le cluster minikube
	minikube delete -p ckad
