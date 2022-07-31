#!/bin/bash

# Completes the steps from ../docs/11-pod-network-routes.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

printf "\nDownload flannel...\n"
wget -q --show-progress --https-only --timestamping \
	"https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml"

printf "\nModify flannel...\n"
patch kube-flannel.yml kube-flannel.yml.patch

printf "\nApply flannel configuration...\n"
kubectl apply -f kube-flannel.yml

printf "\nWait for flannel pods...\n"
POD_NAME=$(kubectl get pods -l app=flannel -n kube-system -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod "${POD_NAME}" -n kube-system

printf "\nChecking flannel pods...\n"
kubectl get pods -l app=flannel -n kube-system
