#!/bin/bash

# Completes the steps from ../docs/09-bootstrapping-kubernetes-workers.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

test -f kubelet && rm cni-plugins-amd64-v0.7.1.tgz kubectl kube-proxy kubelet

wget -q --show-progress --https-only --timestamping \
  https://github.com/containernetworking/plugins/releases/download/v0.7.1/cni-plugins-amd64-v0.7.1.tgz \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.1/bin/linux/amd64/kubelet

# bootstrap each worker host
for instance in worker-0 worker-1 worker-2; do
  vagrant ssh --command /vagrant/09-bootstrapping-kubernetes-workers-members.sh "${instance}"
done
