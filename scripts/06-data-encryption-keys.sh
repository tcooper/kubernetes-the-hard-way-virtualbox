#!/bin/bash

# Completes the steps from ../docs/06-data-encryption-keys.md with
# additional logic / code to allow steps to be rerun multiple times if wanted /
# needed.

printf "\nGenerate an encryption key...\n"
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

printf "\nCreate the Encryption Config File...\n"
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

yq . encryption-config.yaml
