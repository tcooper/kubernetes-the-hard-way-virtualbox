#!/bin/bash

# Completes the steps from ../docs/08-bootstrapping-kubernetes-controllers.md
# with additional logic / code to allow steps to be rerun multiple times if
# wanted / needed.

printf "\nBootstrapping the Kubernetes Control Plane\n"
printf "\nGenerate kubectl for controller nodes...\n"

cat > controller-kubectl-config.yaml <<EOF
apiVersion: v1
clusters:
- cluster:
    server: http://127.0.0.1:8080
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: admin
  name: kubernetes-the-hard-way
current-context: kubernetes-the-hard-way
kind: Config
preferences: {}
EOF

printf "\nDownload the Kubernetes Controller Binaries...\n"

# force re-download of binaries
test -f kubectl && /bin/rm -f kube-apiserver kube-controller-manager kube-scheduler kubectl
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl"

# version links from https://www.downloadkubernetes.com
  #wget -q --show-progress --https-only --timestamping \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kube-apiserver" \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kube-controller-manager" \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kube-scheduler" \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kubectl" \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kube-proxy" \
  #  "https://dl.k8s.io/v1.21.14/bin/linux/amd64/kubeadm"

# bootstrap each control plane host
for instance in controller-0 controller-1 controller-2; do
  printf "\nBootstrapping the Kubernetes Control Plane on ${instance}..."
  vagrant ssh --command /vagrant/08-bootstrapping-kubernetes-controllers-members.sh "${instance}"
  printf "\nVerifying ${instance}...\n"
  vagrant ssh "${instance}" --command "kubectl get componentstatuses"
done

printf "\nConfigure RBAC for Kubelet Authorization\n"

printf "\nCreate system:kube-apiserver-to-kubelet ClusterRole..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
# kubectl get clusterrole system:kube-apiserver-to-kubelet

printf "\nCreate system:kube-apiserver ClusterRoleBinding..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
#kubectl get clusterrolebinding system:kube-apiserver

KUBERNETES_PUBLIC_ADDRESS="192.168.100.100"
vagrant ssh --command "curl --cacert /etc/etcd/ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version" "${instance}"
