#!/usr/bin/env bash
export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null"

ansible-playbook ./site.yml -i ./hosts \
    --vault-id vault_pass \
    -v \
    -u vagrant \
    -e @vault.yml \
    -e @extra_vars/dev.yml \
    "$@"
