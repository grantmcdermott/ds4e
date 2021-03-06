#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$GCP_ENCRYPT_PASSPHRASE" \
--output $HOME/secrets/gcp-ds4e.json .github/workflows/secrets/gcp-ds4e.json.gpg
