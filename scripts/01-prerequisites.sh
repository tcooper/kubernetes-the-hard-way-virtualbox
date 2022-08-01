#!/bin/bash

# Completes the steps from ../docs/01-prerequisites.md with additional
# logic / code to allow steps to be rerun multiple times if wanted / needed.

printf "\nCheck for VirtualBox and Vagrant\n"
which VBoxManage || (printf "You need to install VirtualBox\n"; exit 1)
which vagrant || (printf "You need to install Vagrant\n"; exit 1)

printf "\nInstall vagrant-hosts plugin...\n"
vagrant plugin list | grep -q vagrant-hosts || vagrant plugin install vagrant-hosts

printf "\nValidate vagrant...\n"
vagrant validate
