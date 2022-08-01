#!/bin/bash

# Bootstrap a kubernetes test env in Virtualbox following the model of
# kubernetes-the-hard-way by Kelsey Hightower with Vagrant bits from
# sgargel

# References:
# https://github.com/kelseyhightower/kubernetes-the-hard-way
# https://github.com/sgargel/kubernetes-the-hard-way-virtualbox

printf "\nPrerequisites\n"
./01-prerequisites.sh

printf "\nInstall the Client Tools\n"
./02-client-tools.sh

printf "\nProvision Compute Resources\n"
./03-compute-resources.sh

printf "\nProvision the CA and Generating TLS Certificates\n"
./04-certificate-authority.sh

printf "\nGenerat Kubernetes Configuration Files for Authentication\n"
./05-kubernetes-configuration-files.sh

printf "\nGenerate the Data Encryption Config and Key\n"
./06-data-encryption-keys.sh

printf "\nBootstrap the etcd Cluster\n"
./07-bootstrapping-etcd.sh

printf "\nBootstrap the Kubernetes Control Plane\n"
./08-bootstrapping-kubernetes-controllers.sh

printf "\nBootstrap the Kubernetes Worker Nodes\n"
./09-bootstrapping-kubernetes-workers.sh

printf "\nConfigur kubectl for Remote Access\n"
./10-configuring-kubectl.sh

printf "\nProvision Pod Network Routes\n"
./11-pod-network-routes.sh

printf "\nDeploy the DNS Cluster Add-on\n"
./12-dns-addon.sh

printf "\nSmoke Test\n"
./13-smoke-test.sh

printf "\nCleaning Up\n"
./14-cleanup.sh
