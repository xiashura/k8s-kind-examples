#!/usr/bin/env bash

helm upgrade --install --namespace vault \
  --create-namespace \
  --wait \
  --repo https://helm.releases.hashicorp.com \
  --values ./charts/vault/value.yml vault vault  
kubectl -n vault exec vault-0 -- vault operator init  -key-shares=1  -key-threshold=1  -format=json > cluster-keys.json
jq -r ".unseal_keys_b64[]" cluster-keys.json
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
kubectl -n vault exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl -n vault exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl -n vault exec -ti vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY