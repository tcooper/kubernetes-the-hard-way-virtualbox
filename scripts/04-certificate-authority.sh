#!/bin/bash

# Completes the steps from ../docs/04-certificate-authority.md with additional
# logic / code to allow steps to be rerun multiple times if wanted / needed.

printf "\nProvisioning Certificate Authority...\n"
printf "\nCreate the CA configuration file...\n"
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
jq . ca-config.json

printf "\nCreate the CA certificate signing request...\n"
cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF
jq . ca-csr.json

printf "\nGenerate the CA certificate and private key...\n"
cfssl gencert \
  -initca ca-csr.json | cfssljson -bare ca
openssl x509 -text -noout -in ca.pem

printf "\nProvisioning Client and Server Certificates\n"
printf "\nAdmin Client Certificate\n"
printf "\nCreate the admin client certificate signing request...\n"

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
jq . admin-csr.json

printf "\nGenerate the admin client certificate and private key\n"
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
openssl x509 -text -noout -in admin.pem

printf "\nGenerate the Kubelet Client Certificates\n"
printf "\nGenerate a certificate and private key for each kubernetes worker node...\n"
for instance in worker-0 worker-1 worker-2; do
  cat > "${instance}-csr.json" <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
  jq . "${instance}-csr.json"

  INTERNAL_IP=$(vagrant ssh "${instance}" -- "ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)'")

  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -hostname="${instance},${INTERNAL_IP}" \
    -profile=kubernetes \
    "${instance}-csr.json" | cfssljson -bare "${instance}"
  openssl x509 -text -noout -in "${instance}.pem"
done

printf "\nGenerate the kube-proxy Client Certificate\n"
printf "\nCreate the kube-proxy client certificate signing request...\n"
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
jq . kube-proxy-csr.json

printf "\nGenerate the kube-proxy client certificate and private key...\n"
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
openssl x509 -text -noout -in kube-proxy.pem

printf "\nGenerate the Kubernetes API Server Certificate\n"

KUBERNETES_PUBLIC_ADDRESS="192.168.100.100"

printf "\nCreate kubernetes api server certificate signing request...\n"
cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
jq . kubernetes-csr.json

printf "\nGenerate the kubernetes api server certificate and private key...\n"
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,192.168.100.10,192.168.100.11,192.168.100.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
openssl x509 -text -noout -in kubernetes.pem

printf "\nConcatenate the kubernetes api servier and ca certificates...\n"
cat kubernetes.pem ca.pem > kubernetes-tls-cert-file.pem
openssl x509 -text -noout -in kubernetes-tls-cert-file.pem
