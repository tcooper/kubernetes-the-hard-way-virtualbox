#!/bin/bash

# Completes the steps from ../docs/09-bootstrapping-kubernetes-workers.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

# install dependencies
sudo apt -y install socat containerd

# create install directories
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# install worker binaries
sudo tar -xvf /vagrant/cni-plugins-amd64-v0.7.1.tgz -C /opt/cni/bin/
(cd /vagrant && sudo cp kubectl kube-proxy kubelet /usr/local/bin/)
(cd /usr/local/bin && sudo chmod +x kubectl kube-proxy kubelet)

# get worker internal ip
INTERNAL_IP=$(ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)')

# configure the kubelet
(cd /vagrant && sudo cp ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/)
(cd /vagrant && sudo cp ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig)
(cd /vagrant && sudo cp ca.pem /var/lib/kubernetes/)

cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --anonymous-auth=false \\
  --authorization-mode=Webhook \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --runtime-request-timeout=25m \\
  --tls-cert-file=/var/lib/kubelet/${HOSTNAME}.pem \\
  --tls-private-key-file=/var/lib/kubelet/${HOSTNAME}-key.pem \\
  --v=2 \\
  --node-ip=${INTERNAL_IP}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# configure kubernetes proxy
(cd /vagrant && sudo cp kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig)

cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --cluster-cidr=10.244.0.0/16 \\
  --kubeconfig=/var/lib/kube-proxy/kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# start worker services
sudo mv kubelet.service kube-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable containerd kubelet kube-proxy
sudo systemctl start containerd kubelet kube-proxy
