#!/bin/bash

# Completes the steps from ../docs/02-client-tools.md with additional
# logic / code to allow steps to be rerun multiple times if wanted / needed.

printf "\nInstall the Client Tools\n"
if which brew >/dev/null 2>&1
then
  printf "\nUsing homebrew...\n"

  printf "\nInstall CFSSL...\n"
  brew list cfssl >/dev/null || brew install cfssl
  cfssl version

  printf "\nInstall kubectl...\n"
  brew list kubectl >/dev/null || brew install kubectl
  kubectl version --client

  printf "\nInstall jq...\n"
  brew list jq >/dev/null || brew install jq
  jq --version

  printf "\nInstall k9s...\n"
  brew list k9s >/dev/null || brew install k9s
  k9s version

  printf "\nInstall yq...\n"
  brew list yq >/dev/null || brew install yq
  yq --version
else
  printf "\nInstall CFSSL...\n"
  curl -o cfssl https://pkg.cfssl.org/R1.2/cfssl_darwin-amd64
  curl -o cfssljson https://pkg.cfssl.org/R1.2/cfssljson_darwin-amd64
  chmod +x cfssl cfssljson
  sudo mv cfssl cfssljson /usr/local/bin/
  cfssl version

  printf "\nInstall kubectl...\n"
  curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/darwin/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  kubectl version --client

  printf "\nInstall jq...\n"
  curl -o jq -LR https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64
  chmod +x jq
  sudo mv jq /usr/local/bin
  jq --version

  printf "\nInstall k9s...\n"
  curl -LOR https://github.com/derailed/k9s/releases/download/v0.26.0/k9s_Darwin_x86_64.tar.gz
  tar -xzf k9s_Darwin_x86_64.tar.gz k9s
  chmod +x k9s
  sudo mv k9s /usr/local/bin
  k9s version

  printf "\nInstall yq...\n"

fi
