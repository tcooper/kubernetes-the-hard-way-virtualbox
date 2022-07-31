#!/bin/bash

# Completes the steps from ../docs/12-dns-addon.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

printf "\nDeploy coredns cluster add-on...\n"
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

printf "\nWait for coredns pods...\n"
POD_NAME=$(kubectl get pods -l k8s-app=kube-dns -n kube-system -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod "${POD_NAME}" -n kube-system

printf "\nChecking coredns pods...\n"
kubectl get pods -l k8s-app=kube-dns -n kube-system

printf "\nRun pod...\n"
kubectl run busybox --image=busybox --command -- sleep 3600
kubectl get pods -l run=busybox

printf "\nCreate ClusterRoleBinding allowing inspection...\n"
kubectl create clusterrolebinding apiserver-kubelet-admin --user=kubernetes --clusterrole=system:kubelet-api-admin

printf "\nWait for pod...\n"
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod "${POD_NAME}"

printf "\nVerifying cluster dns...\n"
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
