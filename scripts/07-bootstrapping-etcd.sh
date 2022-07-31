#!/bin/bash

printf "\nBootstrapping the etcd Cluster\n"
printf "\nDownload etcd Binaries...\n"

ETCD_VERSION=3.4.7
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz"

for instance in controller-0 controller-1 controller-2; do
  printf "\nBootstrapping the etcd member ${instance}...\n"
  vagrant ssh --command /vagrant/07-bootstrapping-etcd-member.sh "${instance}"
done

printf "\nVerify configuration...\n"
vagrant ssh --command 'ETCDCTL_API=3 etcdctl member list' "${instance}"
