#!/bin/bash

# Completes the steps from ../docs/05-kubernetes-configuration-files.md with
# additional logic / code to allow steps to be rerun multiple times if wanted /
# needed.

printf "\nClient Authentication Configs\n"

KUBERNETES_PUBLIC_ADDRESS="192.168.100.100"

printf "\nGenerate the kubelet Kubernetes Configuration Files\n"

for instance in worker-0 worker-1 worker-2; do
  printf "\nGenerate a kubeconfig file for %s...\n" "${instance}"

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server="https://${KUBERNETES_PUBLIC_ADDRESS}:6443" \
    --kubeconfig="${instance}.kubeconfig"

  kubectl config set-credentials "system:node:${instance}" \
    --client-certificate="${instance}.pem" \
    --client-key="${instance}-key.pem" \
    --embed-certs=true \
    --kubeconfig="${instance}.kubeconfig"

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:"${instance}" \
    --kubeconfig="${instance}.kubeconfig"

  kubectl config use-context default --kubeconfig="${instance}.kubeconfig"

  yq . "${instance}.kubeconfig"
done

print "\nGenerate a kubeconfig file for the `kube-proxy` service...\n"

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server="https://${KUBERNETES_PUBLIC_ADDRESS}:6443" \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

yq . kube-proxy.kubeconfig
