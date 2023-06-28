#!/usr/bin/env bash

helm upgrade \
  --install \
  --wait \
  --create-namespace \
  --namespace prometheus \
  --repo https://prometheus-community.github.io/helm-charts \
  --values ./charts/prometheus/value.yml \
  prometheus prometheus 