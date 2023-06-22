#!/usr/bin/env bash

helm upgrade --install \
  --wait \
  --create-namespace \
  --namespace argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --values ./charts/argo-cd/value.yml argo-cd argo-cd 