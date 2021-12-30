#!/bin/bash

sudo dnf -y update
sudo dnf -y install '@container-tools' python36-pip

pip3 install --user upgrade pip setuptools wheel

cat << REQUIREMENTS > requirements.txt
jmespath
cryptography
ansible
ansible-galaxy
REQUIREMENTS

pip3 install --user -r requirements.txt

cat << REQUIREMENTS > requirements.yml
---
collections:
- ansible.posix
- containers.podman
- community.crypto
roles:
- jharmison_redhat.redhat_quay
REQUIREMENTS

ansible-galaxy install -r requirements.yml

sudo reboot now
