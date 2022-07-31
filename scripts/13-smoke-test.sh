#!/bin/bash

# Completes the steps from ../docs/13-smoke-test.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

printf "\nData encryption...\n"
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

vagrant ssh controller-0 \
  --command "ETCDCTL_API=3 etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

kubectl delete secret kubernetes-the-hard-way

printf "\nDeployment...\n"
kubectl run nginx --image=nginx
kubectl get pods -l run=nginx

printf "\nWait for pod...\n"
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl wait --for=condition=ready pod "${POD_NAME}"

printf "\nRun the following command in this shell...\n"
printf "\n\tkubectl port-forward %s 8080:80\n" "${POD_NAME}"
printf "\nRun in another shell...\n"
printf "\n\tcurl --head http://127.0.0.1:8080\n"

printf "\nTaking Snapshot of Compute Resources...\n"
vagrant snapshot list | grep -q complete && vagrant snapshot delete complete
vagrant snapshot save complete
vagrant snapshot list
