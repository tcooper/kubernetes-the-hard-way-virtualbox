#!/bin/bash

# Completes the steps from ../docs/07-bootstrapping-etcd.md with
# additional logic / code to allow steps to be rerun multiple times if wanted /
# needed.

printf "\nExtract and install binaries...\n"
ETCD_VERSION=3.4.7
tar -xvf /vagrant/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
sudo mv etcd-v${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/

printf "\nConfigure the etcd Server...\n"
sudo mkdir -p /etc/etcd /var/lib/etcd
(cd /vagrant/ && sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/)
INTERNAL_IP=$(ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)')
ETCD_NAME=$(hostname -s)

printf "\nCreate etcd.service systemd unit file...\n"
cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://192.168.100.10:2380,controller-1=https://192.168.100.11:2380,controller-2=https://192.168.100.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

printf "\nStart the etcd server...\n"
sudo mv etcd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
systemctl --no-pager status etcd.service
