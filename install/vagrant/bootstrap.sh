#!/usr/bin/env bash
set -e

# This file bootstraps a base Centos7 VM so that it can build itself and
# a federated cluster with Ansible.
#

ANSIBLE_DIR=${ANSIBLE_DIR:-/bullwark}

# Install Ansible if we don't already have it
#
command -v ansible >/dev/null 2>&1 || (yum install -y epel-release && yum -y update && yum install -y ansible dos2unix)

cd ${ANSIBLE_DIR}/install/ansible

# We can uncomment this if any private repos are introduced.
#
#echo "Testing credentials..."
#curl -sf -H "Authorization: Basic $(echo -n "${1}:${2}" | base64)" \
#  -X GET \
#  https://api.github.com/users/${1} > \
#  /dev/null || \
#  ( >&2 echo "GitHub authentication failure; please run "\
#  "'vagrant up --provision' again and verify that your credentials are "\
#  "correct. Exiting." && exit 1 )
#
#echo "Credentials are valid. Continuing..."

echo ${3} > vault_pass
echo "---" > vault.yml
echo "email: ${1}" >> vault.yml
echo "password: ${2}" >> vault.yml

ansible-vault encrypt --vault-id vault_pass vault.yml

find . -type f -print0 | xargs -0 dos2unix
./ansible.sh ${4}
