#!/bin/bash

# Completes the steps from ../docs/10-configuring-kubectl.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

KUBERNETES_PUBLIC_ADDRESS="192.168.100.100"

printf "\nSetting cluster in config...\n"
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

printf "\nSetting credentials in config...\n"
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem

printf "\nSetting context in config...\n"
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

printf "\nUsing context kubernetes-the-hard-way...\n"
kubectl config use-context kubernetes-the-hard-way
