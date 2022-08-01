#!/bin/bash

# Completes the steps from ../docs/14-cleanup.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

read -r -p "Are You Sure? [Y/n] " input

case $input in
      [yY][eE][sS]|[yY])
            ;;
      [nN][oO]|[nN])
            exit 0
            ;;
      *)
            echo "Invalid input..."
            exit 1
            ;;
esac

printf "\nRemove the hosts...\n"
vagrant destroy -f

printf "\nRemove kubernetes-the-hard-way cluster and context\n"
kubectl config get-contexts | grep kubernetes-the-hard-way && kubectl config delete-context kubernetes-the-hard-way
kubectl config get-clusters | grep kubernetes-the-hard-way && kubectl config delete-cluster kubernetes-the-hard-way

printf "\nRemove CA config, csr, key and certificate...\n"
/bin/rm -fv ./ca-config.json ./ca-csr.json ./ca-key.pem ./ca.csr ./ca.pem

printf "\nRemove admin config, csr, key and certificate...\n"
/bin/rm -fv ./admin-csr.json ./admin-key.pem ./admin.csr ./admin.pem

printf "\nRemove apiserver config, key and certificates...\n"
/bin/rm -fv ./kubernetes-csr.json ./kubernetes-key.pem ./kubernetes-tls-cert-file.pem \
  ./kubernetes.csr ./kubernetes.pem

printf "\nRemove RBAC configuration...\n"
/bin/rm -fv ./controller-kubectl-config.yaml ./encryption-config.yaml

printf "\nRemove kube-proxy client config, csr, key and certificate...\n"
/bin/rm -fv ./kube-proxy-csr.json ./kube-proxy-key.pem ./kube-proxy.csr \
  ./kube-proxy.pem ./kube-proxy.kubeconfig

printf "\nRemove worker client configs, csrs, keys, and certificates...\n"
/bin/rm -f worker-[0-9]-csr.json worker-[0-9]-key.pem worker-[0-9].csr \
  worker-[0-9].kubeconfig worker-[0-9].pem

printf "\nRemove binaries...\n"
/bin/rm -f ./cni-plugins-amd64-v0.7.1.tgz ./etcd-v3.4.7-linux-amd64.tar.gz \
  ./kube-apiserver ./kube-controller-manager ./kube-proxy ./kube-scheduler \
  ./kubectl ./kubelet cfssl cfssljson jq yq k9s k9s_Darwin_x86_64.tar.gz

printf "\nRemove various...\n"
/bin/rm -f ubuntu-*-cloudimg-console.log kube-flannel.yml
